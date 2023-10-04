##########################################################################
# File: dksdk-cmake/patch-ml.cmake                                       #
#                                                                        #
# Copyright 2023 Diskuv, Inc.                                            #
#                                                                        #
# Licensed under the DkSDK SOFTWARE DEVELOPMENT KIT LICENSE AGREEMENT    #
# (the "License"); you may not use this file except in compliance        #
# with the License. You may obtain a copy of the License at              #
#                                                                        #
#     https://diskuv.com/legal/                                          #
#                                                                        #
##########################################################################

if (NOT DESTDIR)
    message(FATAL_ERROR "The -D DESTDIR=... must be set")
endif()
if (NOT PATCHDIR)
    message(FATAL_ERROR "The -D PATCHDIR=... must be set")
endif()

configure_file("${PATCHDIR}/discover.ml" "${DESTDIR}/src/config/discover.ml" COPYONLY)
configure_file("${PATCHDIR}/src.dune" "${DESTDIR}/src/dune" COPYONLY)

# Fix for https://github.com/mmottl/sqlite3-ocaml/issues/54
#   Move the following: #include <sqlite3.h>
#   to the top of the file.
file(READ "${DESTDIR}/src/sqlite3_stubs.c" sqlite3_stubs_c_CONTENT)
if(NOT sqlite3_stubs_c_CONTENT MATCHES "patch-ml POST[.]EDIT[.]1") # idempotent
    string(REPLACE "#include <sqlite3.h>" "/* patch-ml PRE.EDIT.1: #include <sqlite3.h> */" sqlite3_stubs_c_CONTENT "${sqlite3_stubs_c_CONTENT}")
    string(PREPEND sqlite3_stubs_c_CONTENT "#include <sqlite3.h> /* patch-ml POST.EDIT.1 */\n")
    file(WRITE "${DESTDIR}/src/sqlite3_stubs.c" "${sqlite3_stubs_c_CONTENT}")
endif()
