# Let Lwt use CMake's libev.
if(BUILD_LIBEV)
    get_target_property(libev_INSTALL_DIR libev_Proj LIBEV_INSTALL_DIR)
    if(NOT libev_INSTALL_DIR)
        message(FATAL_ERROR "The LIBEV_INSTALL_DIR project was not set on the libev_Proj target")
    endif()
    configure_file(discover.in.ml discover.ml @ONLY NEWLINE_STYLE UNIX)
    set(declare_available_extra_args
        PATCH_COMMAND
        "${CMAKE_COMMAND}" -E copy_if_different "${CMAKE_CURRENT_BINARY_DIR}/discover.ml" <SOURCE_DIR>/<SOURCE_SUBDIR>/src/unix/config/discover.ml
    )
    message(STATUS "Configuring Lwt with libev")
else()
    set(declare_available_extra_args)
    message(STATUS "Configuring Lwt without libev")
endif()

#   lwt and lwt_react go together ...
DkSDKProject_DeclareAvailable(lwt
        # Why don't we use Opam? As in:
        #   CONSTRAINT ">= 5.6.1"
        # 1. Because we end up with a command line about 9112 characters long, while CMD.EXE only supports 8192
        # on Windows. Precisely:
        #   (cd _build/default && Z:\...\DkSDKFiles\o\s\o\bin\ocamlmklib.opt.exe -g
        #   -o _dk/_opam/.opam-switch/build/lwt.5.6.1/src/unix/lwt_unix_stubs
        #   _dk/_opam/.opam-switch/build/lwt.5.6.1/src/unix/windows_write_job.obj
        #   ... 129 .obj in total ...
        #   _dk/_opam/.opam-switch/build/lwt.5.6.1/src/unix/lwt_libev_stubs.obj -ldopt ws2_32.lib)
        # which has the error:
        #   The command line is too long.
        # 2. Also, this is a good test that we don't have to rely on opam for source code; normal CMake works,
        # and even bundling code in vcpkg and conan might work.
        # 3. We want to bundle our own libev!
        URL https://github.com/ocsigen/lwt/archive/5.6.1.tar.gz
        URL_HASH SHA512=698875bd3bfcd5baa47eb48e412f442d289f9972421321541860ebe110b9af1949c3fbc253768495726ec547fe4ba25483cd97ff39bc668496fba95b2ed9edd8

        ${declare_available_extra_args}

        FINDLIBS
        lwt
        lwt.unix
        )
DkSDKProject_DeclareAvailable(lwt_react
        # This goes along with `lwt`. Because lwt_react.opam is part of lwt project but is fixed at a
        # very old version (1.2.0), the scan unique (ocamldunesu) tool will think lwt_react is an
        # independent project (because they have independent versions). That means both lwt and
        # lwt_react will be visible to Dune, and Dune will error with "Too many opam files for
        # package lwt_react".
        # Solution is simple: Just nullify the "independent" lwt_react 1.2.0 with an empty opam
        # package. Then Dune will look at `lwt.5.6.1+` and see its bundled `lwt_react.opam` (version 1.2.0)
        # and nothing else.
        URL ${CMAKE_CURRENT_LIST_DIR}/lwt_react.1.2.0
        FINDLIBS
        lwt_react # yes, in version 1.2.0 the public name was lwt_react not lwt.react
        )

DkSDKProject_MakeAvailable(lwt lwt_react)

# Original (BUILD_LIBEV AND APPLE):
#   Because long-running macOS `ld -r` partial linking bug is not fixed, the .dylib will not be available
#   when DkSDK does -output-complete-obj to make a Node executable. So we add the .dylib to the
#   INTERFACE.
#   Confer: https://github.com/ocaml/ocaml/issues/7933
# 2023-04-28 (BUILD_LIBEV):
#   All use of Lwt should be linked with ev if it is available. Do not want `new Lwt_engine.libev ()`
#   to fail on Linux/Unix with `Lwt_sys.Not_available("libev_init")`.
#   This is unnecessary if it is static library (but harmless).
if(BUILD_LIBEV)
    target_link_libraries(findlib-lwt.unix INTERFACE ev)
endif()
