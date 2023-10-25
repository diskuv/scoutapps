#include <caml/alloc.h>
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <caml/osdeps.h>
#include <caml/threads.h>
#include <squirrel_scout_manager/squirrel_scout_manager.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int cmp_twodash(SQUIRREL_SCOUT_MANAGER_portable_char *arg) {
#ifdef _MSC_VER
  return wcscmp(L"--", arg);
#else
  return strcmp("--", arg);
#endif
}

static char_os **caml_argv;
static char **c_argv;

void squirrel_scout_manager_init(int argc0, SQUIRREL_SCOUT_MANAGER_portable_char *argv0[],
                                 int *argc, char **argv[]) {
  int i;
  if (argc0 < 1 || argc == NULL || argv0 == NULL || argv == NULL) abort();

  /* Find "--"", if any*/
  int argv0_end_c_excl = argc0;
  for (i = 1; i < argc0; ++i) {
    if (cmp_twodash(argv0[i]) == 0) {
      argv0_end_c_excl = i;
      break;
    }
  }

  /* Make an OCaml argv array, with room for argv0[0] and NULL.
     One way to think of the OCaml argv (especially the arithmetic)
     is that it starts from the "--" option and continues to the
     end of the original argv. And the "--" option would be replaced
     with the original argv[0], although that is irrelevant to
     the arithmetic. */
  int argv0_start_ocaml_inc = argv0_end_c_excl + 1;
  caml_argv = calloc(2 + argc0 - argv0_end_c_excl, sizeof(char_os *));
  caml_argv[0] = argv0[0];
  for (i = argv0_start_ocaml_inc; i < argc0; ++i) {
    caml_argv[1 + i - argv0_start_ocaml_inc] = argv0[i];
  }
  caml_argv[1 + i - argv0_start_ocaml_inc] = NULL;

  /* Run module initializers of OCaml and wait for them to finish */
  caml_startup(caml_argv);

  /* Allow other threads, especially the Qt render thread, to grab
     the OCaml runtime lock and run OCaml code. */
  caml_release_runtime_system();

  /* Make a C argv array, with room for NULL. */
  c_argv = calloc(1 + argv0_end_c_excl, sizeof(char *));
  for (i = 0; i < argv0_end_c_excl; ++i) {
    c_argv[i] = caml_stat_strdup_of_os(argv0[i]);
  }
  c_argv[i] = NULL;

  /* Put NULL at "--", if any, before passing back to C. Yes, C allows argv mutation. */
  *argv = c_argv;
  *argc = argv0_end_c_excl;
}

void squirrel_scout_manager_destroy() {
  /* Dealloc C argv */
  if (c_argv != NULL) {
    for (int i = 0; c_argv[i]; ++i) {
      caml_stat_free(c_argv[i]);
      c_argv[i] = NULL;
    }
    free(c_argv);
  }
  c_argv = NULL;

  /* Dealloc OCaml argv */
  if (caml_argv != NULL) free(caml_argv);
  caml_argv = NULL;

  /* Get the OCaml runtime lock so we can start the OCaml shutdown. */
  caml_acquire_runtime_system();

  /* Release OCaml resources */
  caml_shutdown();
}

void squirrel_scout_manager_consume_qr(
        const char *barcodeFormatName,
        const char *bytesBuf,
        size_t bytesLen) {
  static const value *closure_f = NULL;
  value qr_bytes;
  value qr_format;

  printf("[%s:%d] barcodeFormatName=%s bytesLen=%zu\n", __FILE__, __LINE__, barcodeFormatName, bytesLen);
  fflush(stdout);

  if (closure_f == NULL) {
    closure_f = caml_named_value("squirrel_scout_manager_process_qr");
  }
  if (closure_f == NULL) {
    caml_failwith("The OCaml closure [squirrel_scout_manager_process_qr] "
                  "has not been registered with Callback.register");
  } else {
    qr_format = caml_alloc_initialized_string(strlen(barcodeFormatName), barcodeFormatName);
    qr_bytes = caml_alloc_initialized_string(bytesLen, bytesBuf);
    caml_callback2(*closure_f, qr_format, qr_bytes);
  }
}
