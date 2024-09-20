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

#include <caml/callback.h>

#ifdef _WIN32
#  define portable_main wmain
#  define portable_char wchar_t
#else
#  define portable_main main
#  define portable_char char
#endif

int (portable_main)(int argc, portable_char **argv)
{
  caml_startup (argv);
  caml_shutdown ();
  return 0;
}
