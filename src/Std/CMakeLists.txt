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
        SquirrelScout_Std.ml

        qr_manager.ml
        aws_manager.ml
        main.ml

        db_utils.ml

        match_schedule_table.ml
        raw_match_data_table.ml
        robot_pictures_table.ml
        team_names_table.ml
        )
add_library(SquirrelScout::Std ALIAS SquirrelScout_Std)
set_target_properties(SquirrelScout_Std PROPERTIES EXPORT_NAME Std)

target_sources(SquirrelScout_Std INTERFACE
        SquirrelScout_Std.mli
        # You can use any <name> from add_library(<name> OBJECT xxx/yyy.ml ...).
        #
        # We'll make an OBJECT library later in this file.
        #
        # Not only must you use $<TARGET_OBJECTS:xxx> in target_sources(INTERFACE),
        # you must also add `xxx` to target_link_libraries(PRIVATE). That is because
        # Object Libraries in CMake do not, by default, link to other Object
        # Libraries. Confer "Linking Object Libraries via $<TARGET_OBJECTS>":
        # https://cmake.org/cmake/help/latest/command/target_link_libraries.html#id9
        # If we forget TARGET_OBJECTS, the first build may succeed but changes to
        # .ml/.mli files will not be linked into the final executable if those
        # .ml/.mli files are OBJECT libraries of OBJECT libraries.
        $<TARGET_OBJECTS:transforms>)
target_link_libraries(SquirrelScout_Std PRIVATE
        Findlib::fmt
        # See commentary on target_sources($<TARGET_OBJECTS:xxx>)
        transforms)

# That is not an "exported" OBJECT library visible to other OCaml packages,
# which means you can name the add_library(<unique target>) whatever you want.
# The source files can be in this directory or any subdirectory; the subdirectory name
# is ignored completely.
add_library(
        transforms OBJECT sub1/uppercase.ml 
        my_lwt_extras.ml

        schema.ml
        schema.mli
)



target_link_libraries(transforms PRIVATE
        Findlib::logs.lwt
        Findlib::lwt
       
        Findlib::capnp
        Findlib::vector
        Findlib::yojson  
        Findlib::base64
       
        Findlib::sqlite3
        Findlib::qrc

        #not working
        #Findlib::core

        Findlib::lwt.unix)



# # ----- CAPNP ---- 

# # ----------------------------------------
# # See DkSDK CMake docs for the DKSDK_GOLDEN_SOURCE_CODE variable
# # ----------------------------------------

# # Create a placeholder `Schema` so we can let Dune
# # build the `capnpc-ocaml` binary ... which it can't do
# # if the `(modules schema)` in `dune` has missing `Schema`.
# # Then `capnpc-ocaml` binary can generate a correct
# # `Schema`.
# if(NOT DKSDK_GOLDEN_SOURCE_CODE)
#     if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/schema.ml)
#         file(WRITE ${CMAKE_CURRENT_SOURCE_DIR}/schema.ml
#             "let () = failwith {|placeholder until ${CMAKE_CURRENT_SOURCE_FILE} generates the real schema.ml|}")
#     endif()
# endif()

# # include(FetchContent)
# # FetchContent_GetProperties(dksdk-schema)

# set(std_schema_PLAINDIR ${CMAKE_CURRENT_SOURCE_DIR})
# set(std_schema_PLAIN ${std_schema_PLAINDIR}/schema.capnp)

# # --------------
# # OCaml Message Schema
# # --------------
# if(NOT DKSDK_GOLDEN_SOURCE_CODE)
#     add_custom_command(OUTPUT
#         ${CMAKE_CURRENT_SOURCE_DIR}/schema.ml
#         ${CMAKE_CURRENT_SOURCE_DIR}/schema.mli
#         MAIN_DEPENDENCY
#         ${std_schema_PLAIN}
#         DEPENDS
#         capnproto_host-capnp-exe # Launcher for Cap n' Proto compilers
#         capnpc-ocaml # Cap n' Proto compiler for OCaml
#         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
#         COMMAND

#         # Add capnpc-ocaml.exe for the host ABI to PATH
#         ${CMAKE_COMMAND} -E env
#         PATH=${CMAKE_OCamlDune_DUNE_PROJECT_PATH}/_build/install/default/bin
#         LD_LIBRARY_PATH=${CMAKE_OCamlDune_DUNE_PROJECT_PATH}/_build/install/default/lib
#         $<TARGET_FILE:capnproto_host-capnp-exe>
#         compile
#         ${include_args}
#         --output=ocaml
#         --src-prefix=${std_schema_PLAINDIR}
#         ${std_schema_PLAIN}
#         VERBATIM
#     )
# endif()

# # --------------
# # Targets
# # --------------

# add_custom_target(Squirrel-Scout-GenerateCapnp ALL
#     DEPENDS
#     ${CMAKE_CURRENT_SOURCE_DIR}/schema.ml
#     ${CMAKE_CURRENT_SOURCE_DIR}/schema.mli)