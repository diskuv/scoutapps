##########################################################################
# File: dksdk-cmake/patch-c.cmake                                        #
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

execute_process(
    COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${CMAKE_CURRENT_LIST_DIR}/proj/CMakeLists.txt" "${DESTDIR}"
    COMMAND_ERROR_IS_FATAL ANY)

# Only way to patch from CMake is `git --git-dir= apply`
find_program(GIT_EXECUTABLE git REQUIRED)

execute_process(
    WORKING_DIRECTORY "${DESTDIR}"
    COMMAND "${GIT_EXECUTABLE}" --git-dir= apply "${CMAKE_CURRENT_LIST_DIR}/proj/add-config-include.patch"
    COMMAND "${GIT_EXECUTABLE}" --git-dir= apply "${CMAKE_CURRENT_LIST_DIR}/proj/fix-arm-uwp.patch"
    COMMAND_ERROR_IS_FATAL ANY)

configure_file("${PATCHDIR}/sqlite3-vcpkg-config.h" "${DESTDIR}/sqlite3-vcpkg-config.h" COPYONLY)
