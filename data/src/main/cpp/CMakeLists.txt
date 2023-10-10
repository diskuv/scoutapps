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
target_sources(datalib PRIVATE
        # Use the common-to-all-JDKs JNI code for the Java FFI
        ${dksdk-ffi-java_SOURCE_DIR}/src/dksdk_ffi_java.c
        # Use the Android-specific JNI code for the Java FFI
        ${dksdk-ffi-java_SOURCE_DIR}/ffi-java-android-standalone/src/main/c/jni_defs.c)

# Specifies header files CMake should include when compiling your
# target library.
target_include_directories(datalib PRIVATE
        # The headers for the Android-specific JNI code
        ${dksdk-ffi-java_SOURCE_DIR}/ffi-java-android/src/main/include)

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

# Searches for a specified prebuilt library and stores the path as a
# variable. Because CMake includes system libraries in the search path by
# default, you only need to specify the name of the public NDK library
# you want to add. CMake verifies that the library exists before
# completing its build.

#find_library( # Sets the name of the path variable.
#        log-lib
#
#        # Specifies the name of the NDK library that
#        # you want CMake to locate.
#        log)
