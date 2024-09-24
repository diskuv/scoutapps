include(FetchContent)

if(GENERATE_CAPNP_ONLY)
    if(NOT GENERATE_CAPNP_DIR)
	    message(FATAL_ERROR "Missing GENERATE_CAPNP_DIR variable")
    endif()

    # Get the source code for the OCaml backend
    FetchContent_GetProperties(ocaml-backend)
    if(NOT ocaml-backend_POPULATED)
        FetchContent_Populate(ocaml-backend)
    endif()

    # Create a Java package that contains Schema.java from ocaml-backend
    configure_file(${ocaml-backend_SOURCE_DIR}/src/SonicScout_Std/Schema.java
        ${GENERATE_CAPNP_DIR}/com/example/squirrelscout/data/capnp/Schema.java
        COPYONLY)
else()
    # Get the source code for the Java FFI
    FetchContent_GetProperties(dksdk-ffi-java)

    # Creates a SHARED library called "data_foreground". The Android Gradle
    # Plugin (AGP) will call the CMake target "data_foreground" which will build
    # the library we define here. AGP automatically packages shared
    # libraries with your APK by bundling the shared library into an
    # Android AAR bundle (ie. a JAR with shared libraries).
    add_library(data_foreground SHARED)

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
    target_sources(data_foreground PRIVATE
            register.c # [a1] tweak this comment to force a reconfigure
            ${impl_FILES}
            ${ffi_java_FILES}
            ${ffi_java_android_FILES}
            ${ffi_java_android_standalone_FILES})

    # Specifies header files CMake should include when compiling your
    # target library.
    target_include_directories(data_foreground PRIVATE
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
    target_link_libraries(data_foreground PRIVATE
            # The data backend defined in [ocaml-backend]/src/ObjsLib/CMakeLists.txt.
            # [ocaml-backend] is available as part of our dependencies/ folder.
            SquirrelScout_ObjsLib
            DkSDK_OCamlCompile # REMOVEME: when new SquirrelScout_ObjsLib w/ INTERFACE dependency
            # The Java FFI makes use of some JNI
            JNI::JNI
            # The C FFI is the kernel used by the Java FFI. We link to the
            # static library so we end up with only one .so/.dylib/.dll
            # shared library ("data_foreground"). One shared library is easiest to
            # distribute and easiest to optimize for size.
            DkSDK::FFI::C-StaticExports)
endif()
