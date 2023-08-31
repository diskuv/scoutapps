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
add_library(SquirrelScout_Std OBJECT SquirrelScout_Std.ml)
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
add_library(transforms OBJECT sub1/uppercase.ml my_lwt_extras.ml)
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
