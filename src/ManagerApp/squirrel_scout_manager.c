#include <caml/alloc.h>
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/mlvalues.h>
#include <caml/threads.h>
#include <squirrel_scout_manager/squirrel_scout_manager.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void squirrel_scout_manager_init(int argc0, char *argv0[],
                                 int *argc, char **argv[]) {
  if (argc0 < 1 || argc == NULL || argv0 == NULL || argv == NULL) abort();

  /* Find "--"", if any*/
  int twodash = -1;
  for (int i = 1; i < argc0; ++i) {
    if (strcmp("--", argv0[i]) == 0) {
      /* Replace "--" with argv[0] */
      argv0[i] = argv0[0];
      twodash = i;
      break;
    }
  }

  /* Run module initializers of OCaml and wait for them to finish */
  if (twodash >= 0) {
    caml_startup(argv0 + twodash);
  } else {
    caml_startup(argv0);
  }

  /* Put NULL at "--", if any, before passing back to C */
  if (twodash < 0) {
    *argc = argc0;
    *argv = argv0;
  } else {
    argv[twodash] = NULL;
    *argc = twodash;
    *argv = argv0;
  }
}

void squirrel_scout_manager_destroy() {
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

  caml_acquire_runtime_system();

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

  caml_release_runtime_system();
}
