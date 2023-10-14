# Get the source code for the Java FFI
include(FetchContent)
FetchContent_GetProperties(dksdk-ffi-java)

# Creates a SHARED library called "datalib". The Android Gradle
# Plugin (AGP) will call the CMake target "datalib" which will build
# the library we define here. AGP automatically packages shared
# libraries with your APK by bundling the shared library into an
# Android AAR bundle (ie. a JAR with shared libraries).
add_library(datalib SHARED)

# Provides paths to its source code
file(GLOB impl_FILES LIST_DIRECTORIES FALSE
        "${dksdk-ffi-java_SOURCE_DIR}/src/impl/*.c"
        "${dksdk-ffi-java_SOURCE_DIR}/src/impl/*.h")
file(GLOB ffi_java_FILES LIST_DIRECTORIES FALSE
        "${dksdk-ffi-java_SOURCE_DIR}/ffi-java/src/main/c/*.c"
        "${dksdk-ffi-java_SOURCE_DIR}/ffi-java/src/main/c/*.h")
file(GLOB ffi_java_android_FILES LIST_DIRECTORIES FALSE
        "${dksdk-ffi-java_SOURCE_DIR}/ffi-java-android/src/main/c/*.c"
        "${dksdk-ffi-java_SOURCE_DIR}/ffi-java-android/src/main/c/*.h")
file(GLOB ffi_java_android_standalone_FILES LIST_DIRECTORIES FALSE
        "${dksdk-ffi-java_SOURCE_DIR}/ffi-java-android-standalone/src/main/c/*.c"
        "${dksdk-ffi-java_SOURCE_DIR}/ffi-java-android-standalone/src/main/c/*.h")
target_sources(datalib PRIVATE
        ${impl_FILES}
        ${ffi_java_FILES}
        ${ffi_java_android_FILES}
        ${ffi_java_android_standalone_FILES})

# Specifies header files CMake should include when compiling your
# target library.
target_include_directories(datalib PRIVATE
        "${dksdk-ffi-java_SOURCE_DIR}/src/impl"
        "${dksdk-ffi-java_SOURCE_DIR}/ffi-java/src/main/c"
        "${dksdk-ffi-java_SOURCE_DIR}/ffi-java/src/main/include"
        "${dksdk-ffi-java_SOURCE_DIR}/ffi-java-android/src/main/c"
        "${dksdk-ffi-java_SOURCE_DIR}/ffi-java-android/src/main/include"
        "${dksdk-ffi-java_SOURCE_DIR}/ffi-java-android-standalone/src/main/c"
        "${dksdk-ffi-java_SOURCE_DIR}/ffi-java-android-standalone/src/main/include")

# Specifies libraries CMake should link to your target library. You
# can link multiple libraries, such as libraries you define in this
# build script, prebuilt third-party libraries, or system libraries.
target_link_libraries(datalib PRIVATE
        # The Java FFI makes use of some JNI
        JNI::JNI
        # The C FFI is the kernel used by the Java FFI. We link to the
        # static library so we end up with only one .so/.dylib/.dll
        # shared library ("datalib"). One shared library is easiest to
        # distribute and easiest to optimize for size.
        DkSDK::FFI::C-StaticExports)
