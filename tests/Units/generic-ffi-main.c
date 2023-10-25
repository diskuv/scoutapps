/*************************************************************************
 * File: dksdk-cmake/main.in.c                                           *
 *                                                                       *
 * Copyright 2023 Diskuv, Inc.                                           *
 *                                                                       *
 * Licensed under the DkSDK SOFTWARE DEVELOPMENT KIT LICENSE AGREEMENT   *
 * <https://diskuv.com/legal/> or under the                              *
 * Open Software License version 3.0                                     *
 * <https://opensource.org/license/osl-3-0-php/>, at your option.        *
 * This file may not be copied, modified, or distributed except          *
 * according to those terms.                                             *
 *                                                                       *
 *************************************************************************/

#include "dksdk_ffi_c/dksdk_ffi_c.h"
#include "dksdk_ffi_c/logger/logger.h"
#include <caml/callback.h>

#ifdef _WIN32
#  define portable_main wmain
#  define portable_char wchar_t
#else
#  define portable_main main
#  define portable_char char
#endif

/** Convenience error handling */
#define ON_ERROR(MSG)                                             \
  do {                                                            \
    if (ret != DKSDK_FFI_OK) {                                    \
      fprintf(stderr, "FATAL: " #MSG ". Error code = %d\n", ret); \
      exit(1);                                                    \
    }                                                             \
  } while (0)

int (portable_main)(int argc, portable_char **argv)
{
  int ret;
  int setup_log = 0;
  const char *dklogfilevar;

/*
    THIS LOGGING SETUP SHOULD BE UNNECESSARY.

    Either provide a standard main for FFI, or
    auto-configure the logging if the logs are not
    initialized.
 */

  /* Initialize logging */
  dklogfilevar = getenv("DKSDK_FFI_OCAML_LOG_CONF_FILE");
  if (argc >= 2) {
    char *c_argv1 = caml_stat_strdup_of_os(argv[1]);
    if (c_argv1[0] != '-') {
      ret = dksdk_ffi_c_log_configure(c_argv1);
      ON_ERROR("dksdk_ffi_c_log_configure");
      setup_log = 1;
      /* We need argv in caml_startup() later. C standard
         says we can modify argv (to remove this log option). */
      for (int i = 2; i < argc; ++i) {
        argv[i - 1] = argv[i];
      }
      argv[argc - 1] = NULL;
    }
    caml_stat_free(c_argv1);
  } else if (!setup_log && dklogfilevar != NULL) {
    ret = dksdk_ffi_c_log_configure(dklogfilevar);
    ON_ERROR("dksdk_ffi_c_log_configure");
  } else {
    ret = !dksdk_ffi_c_logger_initConsoleLogger(stderr);
    ON_ERROR("dksdk_ffi_c_logger_initConsoleLogger");
  }

  caml_startup (argv);
  caml_shutdown ();
  return 0;
}
