DkSDKProject_AddPackage(
        AUTO_OPAM_PACKAGE
        SUMMARY_ONELINER "Component object model objects for SquirrelScout."
        SUMMARY_PARAGRAPHS
        [[SquirrelScout_Classes exports the COM class and instance objects.]]
)

# This is the library that will link to Android/iOS applications
add_library(SquirrelScout_Objs STATIC
        SquirrelScout_Objs.ml)
add_library(SquirrelScout::Objs ALIAS SquirrelScout_Objs)
set_target_properties(SquirrelScout_Objs PROPERTIES EXPORT_NAME Objs)
target_link_libraries(SquirrelScout_Objs PRIVATE
        # We want the library that we wrote in ../Std/
        # to be available to the node's .ml code.
        SquirrelScout::Std

        # DkSDK::FFI::OCaml
        Findlib::DkSDKFFIOCaml_Std

        # OCamlCompile is the interface library for the C compile flags. HelloWorld
        # does not actually need it because it has no .c files of its own, but it is
        # safe and recommended to always include it.
        DkSDK::OCamlCompile)
