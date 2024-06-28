# We'll define a NODE and a EXECUTABLE

# ======================= EXECUTABLE =======================

# By default the file is placed in the build directory.
# But we place it in the source directory so it easy to
# set a breakpoint in your favorite C language IDE (CLion, etc.).
DkSDKProject_CreateMainC(OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/_main.c)

add_executable(main-cli _main.c)
target_link_libraries(main-cli PRIVATE
        # We want the CLI node linked into the executable
        SquirrelScout::cli
        # DkSDK::OCaml::Compile is needed for _main.c in hello.
        DkSDK::OCaml::Compile
        # DkSDK::OCaml::ForStaticBinary is because we are doing
        # an add_executable().
        DkSDK::OCaml::ForStaticBinary)
install(TARGETS main-cli DESTINATION ${CMAKE_INSTALL_BINDIR})
set_target_properties(main-cli PROPERTIES OUTPUT_NAME sonic-scout-cli)

DkSDKProject_AddPackage(
        AUTO_OPAM_PACKAGE
        SUMMARY_ONELINER "A simple Hello World executable that demonstrates how to use DkSDK CMake."
        SUMMARY_PARAGRAPHS
        [[SquirrelScout_MainCLI is a TCP/IP echo server that repeats whatever you send it.]]
        [[You can clone the project using the './dk dksdk.project.new' command$<SEMICOLON> see the DkSDK.md document for more information.]]
)

# ======================= NODE =======================

# A node is defined by creating a STATIC library.
#
# --- Naming Rules
#
# You are free to name the STATIC library whatever you like, as long as it uniquely
# named amongst all targets of a CMake project and its subprojects. Since a CMake
# project can be embedded as a subproject in other CMake projects by using
# add_subdirectory(), it is recommended that you prefix the library with the
# name of your project to avoid name collisions.
#
# --- Entry Point
#
# Once you have decided on the name of your library, you must make a .ml file
# with the same name. That .ml file serves as the entry point for the node.
add_library(SquirrelScout_cli STATIC
        SquirrelScout_cli.ml)
add_library(SquirrelScout::cli ALIAS SquirrelScout_cli)
set_target_properties(SquirrelScout_cli PROPERTIES EXPORT_NAME cli)
target_link_libraries(SquirrelScout_cli PRIVATE
        # We want the library that we wrote in ../Std/
        # to be available to the node's .ml code.
        SquirrelScout::Std

        # DkSDK::FFI::OCaml
        # Make command line options. In the node model, each node shares the command line options.
        # You could have a node index and an CLI option with that (ex. --send:2 "hi") if you
        # needed specific options to go to a specific node.
        Findlib::cmdliner
        # Using formatted logs, CLI logging options and color for logging
        Findlib::logs.cli
        Findlib::logs.fmt
        Findlib::fmt.cli
        Findlib::fmt.tty
        DkSDK::OCaml::Compile)
