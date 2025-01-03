DkSDKProject_AddPackage(
        AUTO_OPAM_PACKAGE
        SUMMARY_ONELINER "Auto-registered component object model objects for SquirrelScout."
        SUMMARY_PARAGRAPHS
        [[SquirrelScout_ObjsLib registers the COM class and instance objects.]]
)

# This is the STATIC library that will link to Android/iOS applications.
add_library(SquirrelScout_ObjsLib STATIC SquirrelScout_ObjsLib.ml Init.ml)
add_library(SquirrelScout::ObjsLib ALIAS SquirrelScout_ObjsLib)
target_link_libraries(SquirrelScout_ObjsLib PRIVATE SquirrelScout_Objs)
target_include_directories(SquirrelScout_ObjsLib INTERFACE DkSDK::OCamlCompile)
