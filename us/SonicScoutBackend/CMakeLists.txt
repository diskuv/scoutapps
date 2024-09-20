# New to CMake? Consider purchasing "Professional CMake: A Practical Guide" available
# at https://crascit.com/professional-cmake/. Most things in this project will follow
# the standards there.

# Preamble
cmake_minimum_required(VERSION 3.22)
#   Import the DkSDK framework
#       DkSDK gives you access to the OCamlDune language we'll use soon.
include(FetchContent)
set(REQUEST_DKSDK_VERSION 1.0)
FetchContent_Declare(dksdk-access
    GIT_REPOSITORY https://gitlab.com/diskuv/dksdk-access.git
    GIT_TAG main)
FetchContent_MakeAvailable(dksdk-access)
get_property(dksdk-cmake_MODULES GLOBAL PROPERTY DKSDK_CMAKE_MODULES)
get_property(dksdk-cmake_LANG_ASM GLOBAL PROPERTY DKSDK_CMAKE_LANG_ASM)
list(APPEND CMAKE_MODULE_PATH ${dksdk-cmake_MODULES})

# [Fri, Jan 19, 2024  9:57:01 AM] Failed waiting for concurrent [dune build] using a timeout of 120 seconds. Increasing it!
set(DKSDK_DUNE_LOCK_TIMEOUT_SECS 240 CACHE STRING "" FORCE)

#   Define the project
#       * The VERSION is the version of your application
#       * The "OCamlDune" language is used to build OCaml source code into
#         executables and libraries using Dune.
#           You'll want to use at least the C language so that you can
#           link the native code executables.
#       * OCaml requires the C and a compatible ASM language. ASM should be
#         listed last per best practices
#       * You do not need CXX (C++) compiler unless you bring in your own
#         C++ code or dependencies
project(SonicScout VERSION 1.0.0 LANGUAGES C CXX OCamlDune ${dksdk-cmake_LANG_ASM})

# Project wide setup
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)
#   Optional but recommended; which C standards should be targeted
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED YES)
set(CMAKE_C_EXTENSIONS NO)
#   Necessary only because we have a C++ dependency
#       C++14 needed for capnproto compile feature "cxx_generic_lambdas"
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED YES)
#   Add testing using CTest
include(CTest)
include(CTestUseLaunchers)
#   Add our DkSDK project
include(DkSDKProject)
DkSDKProject_AddProject(
        MAINTAINER "Diskuv Support <support@diskuv.com>"
        LICENSE "DocumentRef-Diskuv-Commercial-1.0:LicenseRef-AllRightsReserved-1"
        SOURCE_URI "git+https://gitlab.com/diskuv/samples/SquirrelScout.git"
        HOMEPAGE_URL "https://diskuv.com/cmake/help/latest"
        BUG_REPORTS_URL "https://gitlab.com/diskuv/samples/SquirrelScout/-/issues"
        DUNE_VERSION 3.8
)

# Externally provided content
add_subdirectory(dependencies)

# Main targets built by this project
add_subdirectory(src)

# Typically needed only if we are the top level project
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    add_subdirectory(tests)
    add_subdirectory(packaging)
else()
    message(NOTICE "Skipping tests and packaging because the current source directory ${CMAKE_CURRENT_SOURCE_DIR} is not the top level source directory ${CMAKE_SOURCE_DIR}")
endif()
