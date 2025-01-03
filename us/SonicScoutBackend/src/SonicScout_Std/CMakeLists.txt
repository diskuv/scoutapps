# This command tells DkSDK that you want to consider this directory and all
# of its subdirectories as belonging to the package "SquirrelScout_Std".
# The package name comes from the name of the project (DkSDKProject_AddProject)
# and from the name of the directory (Std).
DkSDKProject_AddPackage(
        AUTO_OPAM_PACKAGE
        SUMMARY_ONELINER "A simple Hello World library that demonstrates how to use DkSDK CMake."
        SUMMARY_PARAGRAPHS
        [[SquirrelScout_Std is a library that has functions to do upper-casing and thread timeouts.]]
        [[You can clone the project using the './dk dksdk.project.new' command$<SEMICOLON> see the DkSDK.md document for more information.]]
)

# The Findlib:: namespace is for OCaml packages made available primarily in
# dependencies/ through opam, but in the future could be FetchContent directories
# of dune projects. Either way, each Findlib:: library is a CMake interface library
# that can be built (and may build its own transitive dependencies).

# This is the "exported" OBJECT library because it has the same name as
# the package. This library is what other OCaml packages in this project
# will use; even other OCaml projects can use this library if you publish
# it to an opam repository.
add_library(SquirrelScout_Std OBJECT
        StdEntry.ml
        Intf.ml

        Qr_manager.ml
        Aws_manager.ml
        Main.ml

        Db_utils.ml

        Schema.ml
        Schema.mli

        Match_schedule_table.ml
        Raw_match_data_table.ml
        Robot_pictures_table.ml
        Team_names_table.ml

        # This can be removed once DkCoder integrated into DkSDK CMake
        DkSDKFFI_OCaml0.ml
        )
add_library(SquirrelScout::Std ALIAS SquirrelScout_Std)
set_target_properties(SquirrelScout_Std PROPERTIES EXPORT_NAME Std)

target_sources(SquirrelScout_Std INTERFACE
        StdEntry.mli)
target_link_libraries(SquirrelScout_Std PRIVATE
        Findlib::fmt

        Findlib::logs.fmt
        Findlib::logs.lwt
        Findlib::lwt
       
        Findlib::capnp
        Findlib::vector
        Findlib::yojson  
        Findlib::base64
       
        Findlib::sqlite3
        Findlib::qrc
        Findlib::xdg
        Findlib::fpath
        Findlib::bos

        Findlib::lwt.unix)


# ----- CAPNP ---- 

# ----------------------------------------
# See DkSDK CMake docs for the DKSDK_GOLDEN_SOURCE_CODE variable
# ----------------------------------------

# Create a placeholder `Schema` so we can let Dune
# build the `capnpc-ocaml` binary ... which it can't do
# if the `(modules schema)` in `dune` has missing `Schema`.
# Then `capnpc-ocaml` binary can generate a correct
# `Schema`.
if(NOT DKSDK_GOLDEN_SOURCE_CODE)
    if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/Schema.ml)
        file(WRITE ${CMAKE_CURRENT_SOURCE_DIR}/Schema.ml
            "let () = failwith {|placeholder until ${CMAKE_CURRENT_SOURCE_FILE} generates the real Schema.ml|}")
    endif()
endif()

# Capnp --import-path=...
set(import_COMPILE_ARGS
    #   Support `import "/capnp/java.capnp"`
    --import-path=$<TARGET_PROPERTY:capnproto_java_host-lib,CAPNP_JAVA_IMPORT_PATH>)
set(import_DEPENDS
    # include/capnp/java.capnp (schema extensions for Java)
    capnproto_java_host-lib)

# --------------
# OCaml Message Schema
# --------------
if(NOT DKSDK_GOLDEN_SOURCE_CODE)
    add_custom_command(OUTPUT
        ${CMAKE_CURRENT_SOURCE_DIR}/Schema.ml
        ${CMAKE_CURRENT_SOURCE_DIR}/Schema.mli
        MAIN_DEPENDENCY
        schema.capnp
        DEPENDS
        capnproto_host-capnp-exe # Launcher for Cap n' Proto compilers
        capnpc-ocaml # Cap n' Proto compiler for OCaml
        ${import_DEPENDS}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMAND

        # Add capnpc-ocaml.exe for the host ABI to PATH
        ${CMAKE_COMMAND} -E env PATH=${CMAKE_OCamlDune_DUNE_PROJECT_PATH}/_build/install/default/bin
        $<TARGET_FILE:capnproto_host-capnp-exe>
        compile
        ${import_COMPILE_ARGS}
        --output=ocaml
        schema.capnp
        VERBATIM
    )
endif()

# --------------
# Java Message Schema
# --------------
if(NOT DKSDK_GOLDEN_SOURCE_CODE)
    add_custom_command(
            OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/Schema.java
            MAIN_DEPENDENCY
            schema.capnp
            DEPENDS
            capnproto_host-capnp-exe # Launcher for Cap n' Proto compilers
            capnproto_java_host-capnpc-java-exe # capnpc-java.exe (Cap n' Proto compiler for Java)
            ${import_DEPENDS}
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            COMMAND
            #   Add capnpc-java.exe to PATH
            ${CMAKE_COMMAND} -E env
            PATH=$<TARGET_FILE_DIR:capnproto_java_host-capnpc-java-exe>
            LD_LIBRARY_PATH=$<TARGET_FILE_DIR:capnproto_java_host-capnpc-java-exe>/../lib
            #   macOS: https://stackoverflow.com/a/3172515
            DYLD_FALLBACK_LIBRARY_PATH=$<TARGET_FILE_DIR:capnproto_java_host-capnpc-java-exe>/../lib
            #   Run capnp.exe
            $<TARGET_FILE:capnproto_host-capnp-exe>
            compile
            ${import_COMPILE_ARGS}
            --output=java
            schema.capnp
            VERBATIM)
endif()

# --------------
# Targets
# --------------

add_custom_target(Squirrel-Scout-GenerateCapnp ALL
    DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/Schema.ml
    ${CMAKE_CURRENT_SOURCE_DIR}/Schema.mli
    ${CMAKE_CURRENT_SOURCE_DIR}/Schema.java)
