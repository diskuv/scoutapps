#include <caml/callback.h>
#include <caml/memory.h>
#include <jni.h>
#include <dksdk_ffi_c/logger/logger.h>
#include <caml/printexc.h>

#define CAML_INTERNALS
/*  Want caml_print_exception_backtrace() */
#include <caml/backtrace.h>
/*  Want caml_debug_info_available() */
#include <caml/backtrace_prim.h>

#undef CAML_INTERNALS

#ifdef _WIN32
#define os_char wchar_t
#else
#define os_char char
#endif

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
    jobject clazz_name = (*env)->CallObjectMethod(env, clazz, meth_Class_getName); \
    const char *clazz_name_str = (*env)->GetStringUTFChars(env, clazz_name, NULL)

JNIEXPORT void JNICALL
Java_com_example_squirrelscout_data_ComDataService_initializeOCamlRuntime(JNIEnv *env, jclass clazz,
                                                                          jstring process_argv0) {
    /* Get the class name (Ex. ComDataService) for logging */
    GET_CLAZZ_NAME();

    LOG_INFO("[%s.initializeOCaml] Starting", clazz_name_str);

#define RELEASE_INITIALIZEOCAML1() (*env)->ReleaseStringUTFChars(env, clazz_name, clazz_name_str)

    const char *argv0 = (*env)->GetStringUTFChars(env, process_argv0, NULL);
    if (argv0 == NULL) {
        LOG_FATAL("[%s.initializeOCaml] Did not receive the argv0 of the process", clazz_name_str);
        RELEASE_INITIALIZEOCAML1();
        return;
    }

#define RELEASE_INITIALIZEOCAML2() do { (*env)->ReleaseStringUTFChars(env, process_argv0, argv0); RELEASE_INITIALIZEOCAML1(); } while (0)

    os_char *argv0_os = caml_stat_strdup_to_os(argv0);
    if (argv0_os == NULL) {
        LOG_FATAL("[%s.initializeOCaml] OCaml could not duplicate the argv0 of the process",
                  clazz_name_str);
        RELEASE_INITIALIZEOCAML2();
        return;
    }

#define RELEASE_INITIALIZEOCAML3() do { caml_stat_free(argv0_os); RELEASE_INITIALIZEOCAML2(); } while (0)

    os_char *argv[2] = {argv0_os, NULL};
    value res = caml_startup_exn(argv);

    if (Is_exception_result(res)) {
        res = Extract_exception(res);
        handle_ocaml_exception(res, clazz_name_str, "initializeOCamlRuntime");
        RELEASE_INITIALIZEOCAML3();
        return;
    }

    RELEASE_INITIALIZEOCAML3();
    LOG_INFO("[%s.initializeOCaml] Finished", clazz_name_str);
}

JNIEXPORT void JNICALL
Java_com_example_squirrelscout_data_ComDataService_asyncStopOCaml(JNIEnv *env, jclass clazz) {
    /* Get the class name (Ex. ComDataService) for logging */
    GET_CLAZZ_NAME();

    LOG_INFO("[%s.asyncStopOCaml] Starting", clazz_name_str);
    caml_shutdown();
    LOG_INFO("[%s.asyncStopOCaml] Finished", clazz_name_str);
}
