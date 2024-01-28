# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

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

set(languages C)
if(NOT GENERATE_CAPNP_ONLY)
    list(APPEND languages CXX OCamlDune ${dksdk-cmake_LANG_ASM})
endif()
project(SquirrelScoutAndroidApp VERSION 1.0.0 LANGUAGES ${languages})

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_EXTENSIONS NO)
#   Add our DkSDK project
include(DkSDKProject)
if(NOT GENERATE_CAPNP_ONLY)
    DkSDKProject_AddProject(
            MAINTAINER "Diskuv Support <support@diskuv.com>"
            LICENSE "DocumentRef-Diskuv-Commercial-1.0:LicenseRef-AllRightsReserved-1"
            SOURCE_URI "git+https://gitlab.com/diskuv/samples/SquirrelScout.git"
            HOMEPAGE_URL "https://diskuv.com/cmake/help/latest"
            BUG_REPORTS_URL "https://gitlab.com/diskuv/samples/SquirrelScout/-/issues"
            DUNE_VERSION 3.8
    )
endif()

# ---- Third party dependencies

add_subdirectory(dependencies)

if(NOT GENERATE_CAPNP_ONLY)
    # ---- Find JNI
    # TODO: Create DkSDKJava_FindJNI() to replace all of this section

    if(JAVA_HOME)
        message(STATUS "JAVA_HOME = ${JAVA_HOME}")
        cmake_path(NORMAL_PATH JAVA_HOME)
    else()
        message(STATUS "No JAVA_HOME variable set")
    endif()
    include(FindJNI)

    if(NOT JNI_FOUND)
        message(FATAL_ERROR "The JNI headers and library were not found. The JAVA_HOME=${JAVA_HOME} variable should reference a valid JDK")
    endif()

    # FindJNI in CMake 3.24+ defines JNI::JNI and other targets. Backport it.
    if(NOT TARGET JNI::JNI)
        add_library(jni_lib INTERFACE)
        add_library(JNI::JNI ALIAS jni_lib)
        target_sources(jni_lib INTERFACE ${JAVA_INCLUDE_PATH}/jni.h)
        target_include_directories(jni_lib INTERFACE ${JNI_INCLUDE_DIRS})
        target_link_directories(jni_lib INTERFACE ${JNI_LIBRARIES})
    endif()
endif()

# ---- Build source code

add_subdirectory(data/src/main/cpp)
