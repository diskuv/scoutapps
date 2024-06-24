DkSDKProject_AddPackage(
        AUTO_OPAM_PACKAGE
        SUMMARY_ONELINER "Component object model objects for SquirrelScout."
        SUMMARY_PARAGRAPHS
        [[SquirrelScout_Objs expose a register function to register the COM class and instance objects.]]
)

add_library(SquirrelScout_Objs OBJECT
        SquirrelScout_Objs.ml)
target_sources(SquirrelScout_Objs INTERFACE SquirrelScout_Objs.mli)
add_library(SquirrelScout::Objs ALIAS SquirrelScout_Objs)
set_target_properties(SquirrelScout_Objs PROPERTIES EXPORT_NAME Objs)
target_link_libraries(SquirrelScout_Objs PRIVATE
        # We want the library that we wrote in ../Std/
        # to be available to the node's .ml code.
        SquirrelScout_Std

        # DkSDK::FFI::OCaml
        Findlib::DkSDKFFIOCaml_Std)
