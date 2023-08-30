##########################################################################
# File: dksdk-cmake/CMakeLists.txt                                       #
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

# Default ExternalProject_Add(DOWNLOAD_EXTRACT_TIMESTAMP FALSE)
if(POLICY CMP0135)
    cmake_policy(SET CMP0135 NEW)
endif()

include(ExternalProject)

FetchContent_Declare(sqlite3-cmake
    # Confer:
    # https://github.com/microsoft/vcpkg/blob/master/ports/sqlite3/portfile.cmake
    # https://www.sqlite.org/amalgamation.html
    URL https://www.sqlite.org/2023/sqlite-amalgamation-3420000.zip
    URL_HASH SHA512=76416dc40dd15611f59d7209087a08c6cf1b7584dee34da4ce11b75acd7f608d794747a7ed87c3ffe16b237699279c2da8f85b009a379e108d39f33bd727e1e1
)

# Get sqlite3-cmake_SOURCE_DIR
FetchContent_GetProperties(sqlite3-cmake)
if (NOT sqlite3-cmake_POPULATED)
    message(CHECK_START "Fetching sqlite3")
    FetchContent_Populate(sqlite3-cmake)
    message(CHECK_PASS "done")
endif()

# ~~~~~~~~~~~~~~~~~~~~~~
# - Linkage
#
#   Shared or static sqlite3?
#
#   APPLE will always choose the dynamic over the static library if
#   both are present. APPLE goes out of the way to get you to pick
#   dynamic libraries, but as long as you only present a static
#   library, the static library will be linked.
#
#   OCaml produces and consumes static libraries. That is, `.cmxa`
#   are associated with `.a` files, and `/usr/bin/ld -r` on Linux
#   will fail to link `-Lxxx/lib -lsqlite3` if there is only a shared
#   library.
# ~~~~~~~~~~~~~~~~~~~~~~

set(our_build_shared_libs OFF)

# ~~~~~~~~~~~~~~~~~~~~~~
# - Byproducts
if(our_build_shared_libs)
    set(installed_lib ${CMAKE_SHARED_LIBRARY_PREFIX}sqlite3${CMAKE_SHARED_LIBRARY_SUFFIX})
else()
    set(installed_lib ${CMAKE_STATIC_LIBRARY_PREFIX}sqlite3${CMAKE_STATIC_LIBRARY_SUFFIX})
endif()
# ~~~~~~~~~~~~~~~~~~~~~~

# ~~~~~~~~~~~~~~~~~~~~~~
# - Configuration
#
#   https://github.com/microsoft/vcpkg/blob/master/ports/sqlite3/portfile.cmake

if(our_build_shared_libs)
    if(WIN32)
        set(SQLITE_API "__declspec(dllimport)")
    else()
        set(SQLITE_API "__attribute__((visibility(\"default\")))")
    endif()
else()
    set(SQLITE_API "")
endif()

set(cmake_args)
macro(add_option NAME VALUE)
    option(${NAME} "" ${VALUE})
    list(APPEND cmake_args -D "${NAME}=${VALUE}")
endmacro()
add_option(SQLITE_ENABLE_FTS5 ON)
add_option(SQLITE_ENABLE_MATH_FUNCTIONS ON)
add_option(SQLITE_ENABLE_DBSTAT_VTAB ON)
add_option(SQLITE_ENABLE_FTS3 ON)
add_option(SQLITE_ENABLE_FTS4 ON)
add_option(SQLITE_ENABLE_MEMSYS3 ON)
add_option(SQLITE_ENABLE_MEMSYS5 ON)
add_option(SQLITE_ENABLE_UPDATE_DELETE_LIMIT ON)
add_option(SQLITE_ENABLE_RTREE ON)
add_option(SQLITE_ENABLE_SESSION ON)
add_option(SQLITE_ENABLE_PREUPDATE_HOOK ON)
add_option(SQLITE_OMIT_LOAD_EXTENSION ON)
add_option(SQLITE_ENABLE_GEOPOLY ON)
add_option(SQLITE3_SKIP_TOOLS "" OFF)
# is not prefixed with SQLITE* so don't make it an option.
set(WITH_ZLIB OFF)
list(APPEND cmake_args -D WITH_ZLIB=${WITH_ZLIB})

if(WIN32)
    set(SQLITE_OS_WIN "1")
    # We don't care about UWP since it is essentially deprecated for only bug fixes.
    # See https://learn.microsoft.com/en-us/windows/apps/get-started/windows-developer-faq#are-uwp---winui-2-deprecated
    # So just check vcpkg if it is a UWP build
    if(VCPKG_TARGET_IS_UWP)
        set(SQLITE_OS_WINRT "1")
    endif()
else()
    set(SQLITE_OS_UNIX "1")
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/proj/sqlite3-vcpkg-config.h.in" "sqlite3-vcpkg-config.h" @ONLY)

# ~~~~~~~~~~~~~~~~~~~~~~
# - Target
#
#   Convert each of the :FILE variables into absolute paths
foreach(file_var_name IN ITEMS CMAKE_TOOLCHAIN_FILE ANDROID_NDK)
    if(${file_var_name})
        cmake_path(
            ABSOLUTE_PATH ${file_var_name}
            BASE_DIRECTORY ${CMAKE_SOURCE_DIR}
            NORMALIZE
            OUTPUT_VARIABLE ${file_var_name}_ABS)
    endif()
endforeach()
set(our_bin_dir bin)
set(our_include_dir include)
set(our_lib_dir lib)
ExternalProject_Add(sqlite3_Proj
        # The standard subdirectories for ExternalProject_Add can easily waste or exceed the 250
        # CMake Windows absolute path limit
        BINARY_DIR              "${CMAKE_CURRENT_BINARY_DIR}/build"
        INSTALL_DIR             "${CMAKE_CURRENT_BINARY_DIR}/install"
        LOG_DIR                 logs
        LOG_BUILD               YES
        LOG_TEST                YES
        LOG_MERGED_STDOUTERR    YES

        # URL rather than SOURCE_DIR let's us do patches non-destructively
        URL              "${sqlite3-cmake_SOURCE_DIR}"
        PATCH_COMMAND
        "${CMAKE_COMMAND}"
        -D "DESTDIR=<SOURCE_DIR>/<SOURCE_SUBDIR>"
        -D "PATCHDIR=${CMAKE_CURRENT_BINARY_DIR}"
        -P "${CMAKE_CURRENT_LIST_DIR}/patch-c.cmake"

        CMAKE_ARGS
            --no-warn-unused-cli
            -D CMAKE_WARN_DEPRECATED=FALSE
            -D BUILD_SHARED_LIBS=${our_build_shared_libs}
            -D "CMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE_ABS}"
            -D "CMAKE_INSTALL_PREFIX=<INSTALL_DIR>"
            -D "CMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}"
            -D "CMAKE_EXE_LINKER_FLAGS=${CMAKE_EXE_LINKER_FLAGS}"
            -D "CMAKE_MODULE_LINKER_FLAGS=${CMAKE_MODULE_LINKER_FLAGS}"
            -D "CMAKE_SHARED_LINKER_FLAGS=${CMAKE_SHARED_LINKER_FLAGS}"
            -D "CMAKE_STATIC_LINKER_FLAGS=${CMAKE_STATIC_LINKER_FLAGS}"
            -D "CMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}"
            -D "CMAKE_APPLE_SILICON_PROCESSOR=${CMAKE_APPLE_SILICON_PROCESSOR}"
            -D "ANDROID_ABI=${ANDROID_ABI}"
            -D "ANDROID_NDK=${ANDROID_NDK_ABS}"
            -D "ANDROID_PLATFORM=${ANDROID_PLATFORM}"
            -D "CMAKE_INSTALL_BINDIR=${our_bin_dir}"
            -D "CMAKE_INSTALL_INCLUDEDIR=${our_include_dir}"
            -D "CMAKE_INSTALL_LIBDIR=${our_lib_dir}"
            ${cmake_args}

        # Make outputs known to Ninja and other generators
        BUILD_BYPRODUCTS
        <BINARY_DIR>/${installed_lib}
        <INSTALL_DIR>/${our_lib_dir}/${installed_lib}
        )

# ~~~~~~~~~~~~~~~~~~~~~~
# - Export Variables

# Get BINARY_DIR and INSTALL_DIR variables
ExternalProject_Get_property(sqlite3_Proj BINARY_DIR INSTALL_DIR)

foreach(tgt sqlite3)
    # ~~~~~~~~~~~~~~~~~~~~~~
    # BUILD time, for linking to executables that have not been installed, with
    # rpath set to hardcoded development directories.
    # - Target
    add_library(${tgt}-build STATIC IMPORTED GLOBAL)
    # - Dependencies
    add_dependencies(${tgt}-build sqlite3_Proj)
    # - Properties
    set_target_properties(${tgt}-build PROPERTIES
            IMPORTED_LOCATION
            ${BINARY_DIR}/${installed_${tgt}_lib}
            FOLDER "CMake Dependencies"
            )
    target_include_directories(${tgt}-build INTERFACE ${INSTALL_DIR}/${our_include_dir})
    # ~~~~~~~~~~~~~~~~~~~~~~

    # ~~~~~~~~~~~~~~~~~~~~~~
    # BUILD time, for linking to executables that have been installed, with
    # rpath set to relative install-time directories.
    # - Target
    add_library(${tgt}-install STATIC IMPORTED GLOBAL)
    # - Dependencies
    add_dependencies(${tgt}-install sqlite3_Proj)
    # - Properties
    set_target_properties(${tgt}-install PROPERTIES
            IMPORTED_LOCATION
            ${INSTALL_DIR}/${our_lib_dir}/${installed_${tgt}_lib}
            FOLDER "CMake Dependencies"
            )
    target_include_directories(${tgt}-install INTERFACE ${INSTALL_DIR}/${our_include_dir})
    # ~~~~~~~~~~~~~~~~~~~~~~

    # ~~~~~~~~~~~~~~~~~~~~~~
    # - Target
    add_library(${tgt} INTERFACE)
    target_link_libraries(${tgt} INTERFACE
            $<BUILD_INTERFACE:${tgt}-build>
            $<INSTALL_INTERFACE:${tgt}-install>)
    # ~~~~~~~~~~~~~~~~~~~~~~
endforeach()

set_target_properties(sqlite3_Proj PROPERTIES
        LIBSQLITE3_INSTALL_DIR ${INSTALL_DIR})

# ~~~~~~~~~~~~~~~~~~~~~~
# - Packaging for DkSDK

cmake_path(APPEND INSTALL_DIR ${our_lib_dir} OUTPUT_VARIABLE sqlite3_LIBDIR)

configure_file(discover.in.ml discover.ml @ONLY NEWLINE_STYLE UNIX)
configure_file(src.in.dune src.dune @ONLY NEWLINE_STYLE UNIX)

DkSDKProject_DeclareAvailable(sqlite3
    URL https://github.com/mmottl/sqlite3-ocaml/releases/download/5.1.0/sqlite3-5.1.0.tbz
    URL_HASH SHA512=a5e3070f95ccfaffd51de7081d55a204a24d3d277a87fab985a0418e5dd1478ed0462ebaa4dbd4a8bbaf75edd1e216300601d033a7cf8ab2a8ed3b88bbcb9e64
    PATCH_COMMAND
    "${CMAKE_COMMAND}"
    -D "DESTDIR=<SOURCE_DIR>/<SOURCE_SUBDIR>"
    -D "PATCHDIR=${CMAKE_CURRENT_BINARY_DIR}"
    -P "${CMAKE_CURRENT_LIST_DIR}/patch-ml.cmake"
    FINDLIBS sqlite3
)
DkSDKProject_MakeAvailable(sqlite3)

add_dependencies(findlib-sqlite3 sqlite3_Proj)
