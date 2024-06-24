#include <jni.h>
#include <dksdk_ffi_c/logger/logger.h>

#define OCAML_LIFECYCLE_ENTIRE_PROCESS

#define CAML_INTERNALS
#define CAML_NAME_SPACE
#include <caml/callback.h>
#include <caml/memory.h>
#include <caml/printexc.h>
/*  Want caml_print_exception_backtrace() */
#include <caml/backtrace.h>
/*  Want caml_debug_info_available() */
#include <caml/backtrace_prim.h>
/*  Want caml_compact_heap() */
#include <caml/compact.h>
/*  Want caml_debugger_init() */
#include <caml/debugger.h>
/*  Want caml_domain_state (CAML_INTERNALS) */
/*  No redefined variable names for compatibility.h deprecations (CAML_NAME_SPACE) */
#include <caml/domain_state.h>
/*  Want caml_free_shared_libs() */
#include <caml/dynlink.h>
/*  Want caml_finalise_heap() */
#include <caml/major_gc.h>
/*  Want struct skiplist and caml_skiplist_init() */
#include "caml/skiplist.h"
/*  Want caml_init_signals() and caml_terminate_signals() */
#include <caml/signals.h>
/*  Want caml_globals */
#include <caml/stack.h>
/*  Want caml_free_locale() */
#include <caml/startup_aux.h>
/*  Want caml_sys_init() */
#include <caml/sys.h>

#undef CAML_NAME_SPACE
#undef CAML_INTERNALS

#ifdef _WIN32
#define os_char wchar_t
#else
#define os_char char
#endif

// From [ocaml]/runtime/startup_aux.c
#ifdef _WIN32
extern void caml_win32_unregister_overflow_detection (void);
#endif

// From [ocaml]/runtime/globroots.c
extern struct skiplist caml_global_roots;
extern struct skiplist caml_global_roots_young;
extern struct skiplist caml_global_roots_old;

// From [ocaml]/runtime/startup_nat.c
extern value caml_start_program (caml_domain_state*);

static void handle_ocaml_exception(value exn, const char *what, const char *what2) {
    /* Modeled after ocaml/ocaml printexc.c:default_fatal_uncaught_exception() */

    /* Build a string representation of the exception */
    char *exn_msg = caml_format_exception(exn);

    /* Display the uncaught exception */
    LOG_ERROR("[%s.%s] %s", what, what2, exn_msg);
    caml_stat_free(exn_msg);

    /* Display the backtrace if available. Sadly goes to [stderr]! */
    if (caml_debug_info_available())
        caml_print_exception_backtrace();
}

#define GET_CLAZZ_NAME() \
    jclass cls_Class = (*env)->FindClass(env, "java/lang/Class"); \
    jmethodID meth_Class_getName = (*env)->GetMethodID(env, cls_Class, "getName", "()Ljava/lang/String;"); \
    jobject clazz_name = (*env)->CallObjectMethod(env, cls, meth_Class_getName); \
    const char *clazz_name_str = (*env)->GetStringUTFChars(env, clazz_name, NULL)

#ifndef OCAML_LIFECYCLE_ENTIRE_PROCESS
// From [ocaml]/runtime/startup_aux.c
static void call_registered_value(char* name) {
  const value *f = caml_named_value(name);
  if (f != NULL)
    caml_callback_exn(*f, Val_unit);
}

static void do_stop_ocaml() {
    /* Mimic caml_shutdown. Confer D01 in COM-DATA-DESIGN.md */
    call_registered_value("Pervasives.do_at_exit");
    call_registered_value("Thread.at_shutdown");
    caml_finalise_heap();
    /* Reset the major heap to get rid of those "nonexistent values"
       mentioned in caml_finalise_heap.
       Confer D01 in COM-DATA-DESIGN.md.

       Also:
       > if [new_allocation_policy] is -1, the policy is not changed. */
    caml_compact_heap(-1);

    /* Get rid of the global and generational roots.

       But we have a problem when these mostly `static value` global
       variables are restarted ... they will have a value that
       points to the old finalised heap. The problematic global
       variables are:
       - `caml_signal_handlers` must start as zero
       - `Caml_state->backtrace_last_exn = Val_unit` (from domain.c)
       
       So first set all the global root values to 0 and manually set
       other roots to an initial value that works. We can only
       do that for `caml_global_roots` because of
       "The invariant of the generational roots" described in
       globroots.c.

       Then can clear the roots. */
    FOREACH_SKIPLIST_ELEMENT(e, &caml_global_roots, {
      value * r = (value *) (e->key);
      *r = 0;
    });
    Caml_state->backtrace_last_exn = Val_unit;
    caml_skiplist_init(&caml_global_roots);
    caml_skiplist_init(&caml_global_roots_young);
    caml_skiplist_init(&caml_global_roots_old);

    /* Get rid of the local stack.
    
       The stack is just a linked list that ends with a NULL pointer. */
    caml_globals[0] = 0;
}
#endif

static int ocaml_initialized;
static int ocaml_terminated;

JNIEXPORT jboolean JNICALL
Java_com_example_squirrelscout_data_OCamlServiceHandler_init_1ocaml(JNIEnv *env, jclass cls,
                                                                    jstring process_argv0) {
    /* Only initialize OCaml with caml_startup once. Confer D01 in COM-DATA-DESIGN.md */
    if (ocaml_initialized) return JNI_FALSE;
    ocaml_initialized = 1;

    /* Get the class name (Ex. ComDataService) for logging */
    GET_CLAZZ_NAME();

    LOG_INFO("[%s.init_ocaml] Starting", clazz_name_str);

    /* Convert process_argv0 into argv */

#define RELEASE_INIT_OCAML1() (*env)->ReleaseStringUTFChars(env, clazz_name, clazz_name_str)

    const char *argv0 = (*env)->GetStringUTFChars(env, process_argv0, NULL);
    if (argv0 == NULL) {
        LOG_FATAL("[%s.init_ocaml] Did not receive the argv0 of the process", clazz_name_str);
        RELEASE_INIT_OCAML1();
        return JNI_FALSE;
    }

#define RELEASE_INIT_OCAML2() do { (*env)->ReleaseStringUTFChars(env, process_argv0, argv0); RELEASE_INIT_OCAML1(); } while (0)

    os_char *argv0_os = caml_stat_strdup_to_os(argv0);
    if (argv0_os == NULL) {
        LOG_FATAL("[%s.init_ocaml] OCaml could not duplicate the argv0 of the process",
                  clazz_name_str);
        RELEASE_INIT_OCAML2();
        return JNI_FALSE;
    }

#define RELEASE_INIT_OCAML3() do { caml_stat_free(argv0_os); RELEASE_INIT_OCAML2(); } while (0)

    os_char *argv[2] = {argv0_os, NULL};
    value res = caml_startup_exn(argv);

    if (Is_exception_result(res)) {
        res = Extract_exception(res);
        handle_ocaml_exception(res, clazz_name_str, "init_ocaml");
        RELEASE_INIT_OCAML3();
        return JNI_FALSE;
    }

#ifndef OCAML_LIFECYCLE_ENTIRE_PROCESS
    /* Get ready for start state by removing all allocations. Confer D01 in COM-DATA-DESIGN.md */
    do_stop_ocaml();
#endif

    RELEASE_INIT_OCAML3();
    LOG_INFO("[%s.init_ocaml] Finished", clazz_name_str);
    return JNI_TRUE;
}

JNIEXPORT void JNICALL
Java_com_example_squirrelscout_data_OCamlServiceHandler_start_1ocaml(JNIEnv *env, jclass cls,
                                                                          jstring process_argv0) {
    (void)env;
    (void)cls;

    /* Get the class name (Ex. ComDataService) for logging */
    GET_CLAZZ_NAME();

    LOG_INFO("[%s.start_ocaml] Starting", clazz_name_str);

#ifdef OCAML_LIFECYCLE_ENTIRE_PROCESS
    (void) process_argv0;

    /* https://github.com/ocaml/ocaml/issues/11486 */
    caml_init_signals();
#else
    char_os * exe_name;
    /* Convert process_argv0 into argv */

#define RELEASE_START_OCAML1() (*env)->ReleaseStringUTFChars(env, clazz_name, clazz_name_str)

    const char *argv0 = (*env)->GetStringUTFChars(env, process_argv0, NULL);
    if (argv0 == NULL) {
        LOG_FATAL("[%s.start_ocaml] Did not receive the argv0 of the process", clazz_name_str);
        RELEASE_START_OCAML1();
        return;
    }

#define RELEASE_START_OCAML2() do { (*env)->ReleaseStringUTFChars(env, process_argv0, argv0); RELEASE_START_OCAML1(); } while (0)

    os_char *argv0_os = caml_stat_strdup_to_os(argv0);
    if (argv0_os == NULL) {
        LOG_FATAL("[%s.start_ocaml] OCaml could not duplicate the argv0 of the process",
                  clazz_name_str);
        RELEASE_START_OCAML2();
        return;
    }

    os_char *argv[2] = {argv0_os, NULL};

    /* Do opposite of caml_terminate_signals. Confer D01 in COM-DATA-DESIGN.md */
    caml_init_signals();

    /* Do all possible allocations of caml_startup() */
    caml_init_backtrace();
    caml_debugger_init ();
    exe_name = argv[0];
    caml_sys_init(exe_name, argv);
    (void) caml_start_program(Caml_state);
#endif

    LOG_INFO("[%s.start_ocaml] Finished", clazz_name_str);
}

JNIEXPORT void JNICALL
Java_com_example_squirrelscout_data_OCamlServiceHandler_stop_1ocaml(JNIEnv *env, jclass cls) {
    /* Get the class name (Ex. ComDataService) for logging */
    GET_CLAZZ_NAME();

    LOG_INFO("[%s.stop_ocaml] Starting", clazz_name_str);

#ifndef OCAML_LIFECYCLE_ENTIRE_PROCESS
    do_stop_ocaml();
#endif

    LOG_INFO("[%s.stop_ocaml] Finished", clazz_name_str);
}

JNIEXPORT void JNICALL
Java_com_example_squirrelscout_data_OCamlServiceHandler_terminate_1ocaml(JNIEnv *env, jclass cls) {
    /* If never initialized OCaml, nothing to do. */
    if (!ocaml_initialized) return;
    /* Only terminate OCaml with caml_shutdown once. */
    if (ocaml_terminated) return;
    ocaml_terminated = 1;

    /* Get the class name (Ex. ComDataService) for logging */
    GET_CLAZZ_NAME();

    LOG_INFO("[%s.terminate_ocaml] Starting", clazz_name_str);

#ifndef OCAML_LIFECYCLE_ENTIRE_PROCESS
    /* Do all the caml_shutdown() bits of stop_ocaml that have not been done yet.

       Except:
       - `call_registered_value("Thread.at_shutdown")`

       Confer D01 in COM-DATA-DESIGN.md
     */
    caml_free_locale();
    /* We compile for native. So skip:
        caml_free_shared_libs(); */
    /* We do not use caml_startup_pooled() in init_ocaml. So skip:
       caml_stat_destroy_pool(); */
    caml_terminate_signals();
#ifdef _WIN32
    caml_win32_unregister_overflow_detection();
#endif
#endif

    LOG_INFO("[%s.terminate_ocaml] Finished", clazz_name_str);
}

JNIEXPORT void JNICALL
Java_com_example_squirrelscout_data_OCamlServiceHandler_atexit_1ocaml(JNIEnv *env,
                                                                           jclass cls) {
    (void)env;
    (void)cls;

    /* If never initialized OCaml, nothing to do. */
    if (!ocaml_initialized) return;

    /* Get the class name (Ex. ComDataService) for logging */
    GET_CLAZZ_NAME();

    LOG_INFO("[%s.at_exit_ocaml] Starting", clazz_name_str);

#ifdef OCAML_LIFECYCLE_ENTIRE_PROCESS
    caml_shutdown();
#endif

    LOG_INFO("[%s.at_exit_ocaml] Finished", clazz_name_str);
}