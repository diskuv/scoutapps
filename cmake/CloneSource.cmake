# TLDR: Consider this to be similar to .gitignore for the entire project.
#
# Summary: Clone the source code of this project.
#
# When: Used when another project uses this project with
# DkSDKFetchContent_DeclareButAllowLocalOverride(). For example, another project may
# use this project (pretend it is called "this-project") with the following:
#
#     DkSDKFetchContent_DeclareButAllowLocalOverride(
#         NAME this-project
#         GIT_REPOSITORY "https://github.com/you/this-project.git"
#         GIT_TAG main)
#     DkSDKFetchContent_MakeAvailableNoInstall(this-project)
#
# How: This script will be run as a
# `cmake -D CMAKE_INSTALL_PREFIX=... -P cmake/CloneSource.cmake` command from
# the base of this project (the directory that has ./dk, ./dk.cmd and dune-project).
#
# Consequences: Without this script present ALL of _this_ project is copied
# into the build folder of _that_ project. Which can be INCREDIBLY
# TIME-CONSUMING when you have huge build folders and so on in this project.
#
# Suggestions?
#   Ignore test folders. Why does another project need to run your tests?
#
#   See https://cmake.org/cmake/help/latest/command/file.html#copy-file for
#   all the options you can use.
#
#   For debugging, you should use file(INSTALL ...) rather than file(COPY ...)
#   so you can see what is being copied.

if(NOT CMAKE_INSTALL_PREFIX)
    message(FATAL_ERROR "You cannot run this script without setting CMAKE_INSTALL_PREFIX")
endif()

file(INSTALL
     # Directories (don't use trailing slash)
     src data dependencies opam
     # Dune files
     _all_cmake.dune dune dune-project
     # CMake files
     CMakeLists.txt CMakePresets.json
     DESTINATION "${CMAKE_INSTALL_PREFIX}"
     NO_SOURCE_PERMISSIONS
     FOLLOW_SYMLINK_CHAIN)
