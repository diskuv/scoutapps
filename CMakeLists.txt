# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

cmake_minimum_required(VERSION 3.22)

# Import the DkSDK framework
include(FetchContent)
set(REQUEST_DKSDK_VERSION 1.0)
FetchContent_Declare(dksdk-access
    GIT_REPOSITORY https://gitlab.com/diskuv/dksdk-access.git
    GIT_TAG main)
FetchContent_MakeAvailable(dksdk-access)
get_property(dksdk-cmake_MODULES GLOBAL PROPERTY DKSDK_CMAKE_MODULES)
list(APPEND CMAKE_MODULE_PATH ${dksdk-cmake_MODULES})

project(Scouter)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_EXTENSIONS NO)

# ---- Third party dependencies

if(IS_DIRECTORY dependencies)
    add_subdirectory(dependencies)
endif()

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

message(STATUS "JNI_GENERATED_HEADERS = ${JNI_GENERATED_HEADERS}")

# ---- Build source code

add_subdirectory(data/src/main/cpp)
