message(CHECK_START "Configuring ManagerApp")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

DkSDKProject_AddPackage(
        AUTO_OPAM_PACKAGE
        SUMMARY_ONELINER "The Manager App."
        SUMMARY_PARAGRAPHS
        [[SquirrelScout_ManagerApp is ... fill me in ....]]
)

include (GNUInstallDirs)

# Threading library
set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
set(THREADS_PREFER_PTHREAD_FLAG FALSE) # TRUE interacts poorly with OCaml static libraries on Linux
include(FindThreads)
if(NOT Threads_FOUND)
    message(FATAL_ERROR "No Threads library found")
endif()
find_package(Threads REQUIRED)

# Qt library. The Qt directories are populated by scoutapps/src/SonicScout_Setup/Qt.ml
if(MSVC AND IS_DIRECTORY ${PROJECT_SOURCE_DIR}/5.15.2/msvc2019_64/lib/cmake/Qt5 AND NOT Qt5_DIR)
    set(Qt5_DIR ${PROJECT_SOURCE_DIR}/5.15.2/msvc2019_64/lib/cmake/Qt5 CACHE FILEPATH "Qt5 installation directory")
elseif(APPLE AND IS_DIRECTORY ${PROJECT_SOURCE_DIR}/5.15.2/clang_64/lib/cmake/Qt5 AND NOT Qt5_DIR)
    set(Qt5_DIR ${PROJECT_SOURCE_DIR}/5.15.2/clang_64/lib/cmake/Qt5 CACHE FILEPATH "Qt5 installation directory")
elseif(LINUX AND IS_DIRECTORY ${PROJECT_SOURCE_DIR}/5.15.2/gcc_64/lib/cmake/Qt5 AND NOT Qt5_DIR)
    set(Qt5_DIR ${PROJECT_SOURCE_DIR}/5.15.2/gcc_64/lib/cmake/Qt5 CACHE FILEPATH "Qt5 installation directory")
endif()

# ------
# The OCaml code
# ------

add_library(ManagerApp_ml STATIC ManagerApp_ml.ml)
add_library(SquirrelScout::ManagerApp_ml ALIAS ManagerApp_ml)
target_link_libraries(ManagerApp_ml PRIVATE
    # We want the library that we wrote in ../Std/
    # to be available to the node's .ml code.
    SquirrelScout::Std)
# ------
# The C code that calls OCaml
# ------

add_library(ManagerApp_c STATIC squirrel_scout_manager.c)
add_library(SquirrelScout::ManagerApp_c ALIAS ManagerApp_c)
target_link_libraries(ManagerApp_c
    PRIVATE DkSDK::OCaml::Compile
    PUBLIC Threads::Threads
    # The manager app will be a binary that statically links
    # to OCaml (dynamic linking is not required because we
    # are not mixing multiple libraries that use OCaml, and
    # would have been more complicated to deploy).
    DkSDK::OCaml::ForLibOfStaticBinary)
target_include_directories(ManagerApp_c PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

# ------
# This section is a trimmed version of build_dev/_deps/zxing-cpp-src/example/CMakeLists.txt
#
# - The names of the targets have changed from ZXing* to ManagerApp*. However, the names of
#   the source code files is the same.
# - Only the BUILD_READER targets were used
# - There are additions marked in ADDITIONS.
# ------

zxing_add_package_stb()

include (GNUInstallDirs)

add_executable (ManagerAppReader ZXingReader.cpp)

target_link_libraries (ManagerAppReader ZXing::ZXing stb::stb)

# SCOUT:MOVED to tests/Units/ManagerApp: add_test(NAME ManagerAppReaderTest COMMAND ManagerAppReader -fast -format qrcode test.png) # see above

# SCOUT:REMOVED: install(TARGETS ManagerAppReader DESTINATION ${CMAKE_INSTALL_BINDIR})

find_package(Qt5 COMPONENTS Gui Multimedia Quick QUIET)
if (NOT (Qt5_FOUND OR Qt6_FOUND))
    message("INFO: Qt (Gui/Multimedia/Quick) not found, skipping Qt examples")
endif()

# SCOUT:ADDED
get_target_property(qmake_LOC Qt5::qmake IMPORTED_LOCATION)
get_filename_component(qmake_BIN "${qmake_LOC}" DIRECTORY)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

if (TARGET Qt::Gui)
    add_executable (ManagerAppQtReader ZXingQtReader.cpp ZXingQtReader.h)
    target_link_libraries(ManagerAppQtReader ZXing::ZXing Qt::Gui)
endif()

if (TARGET Qt::Multimedia AND TARGET Qt::Quick)
# We'll need this for the MACOSX_BUNDLE and is recommended with
# >The install RPATH details should also be used at build time so that embedded frameworks are handled correctly.
# by Professional CMake.

    add_executable(ManagerAppQtCamReader MACOSX_BUNDLE
        # Do not set `WIN32` since sets /SUBSYSTEM: to Windows Gui not Windows Console.
        # That means console won't be allocated and OCaml's call of write() will fail
        # at first console write. 
        # [0x0]   ucrtbased!_write   0xebc0dff4f8   0xd041cb   
        # [0x1]   SonicScoutQRScanner!caml_write_fd+0x3b   0xebc0dff500   0xfacdd0   
        # [0x2]   SonicScoutQRScanner!caml_flush_partial+0x60   0xebc0dff540   0xfacea4   
        # [0x3]   SonicScoutQRScanner!caml_flush+0x14   0xebc0dff590   0xfae2f0   
        # [0x4]   SonicScoutQRScanner!caml_ml_flush+0x110   0xebc0dff5c0   0xfb1148   
        # [0x5]   SonicScoutQRScanner!caml_c_call+0x28   0xebc0dff670   0x257a2d2beb8   
        # [0x6]   0x257a2d2beb8!+   0xebc0dff678   0x257a2d09828   
        # [0x7]   0x257a2d09828!+   0xebc0dff680   0x257a2d2af38   
        # [0x8]   0x257a2d2af38!+   0xebc0dff688   0x104d908   
        # [0x9]   SonicScoutQRScanner!camlStdlib__Format__pp_print_newline_937+0x18   0xebc0dff690   0x257a2d2af38   
        # [0xa]   0x257a2d2af38!+   0xebc0dff698   0x10509ae   
        # [0xb]   SonicScoutQRScanner!camlStdlib__Format__fun_2958+0x2e   0xebc0dff6a0   0x257a2d0a558   
        # Confer: https://discourse.cmake.org/t/controlling-visual-studio-options-from-cmake/6581/4
        ZXingQtCamReader.cpp ZXingQtCamReader.qrc ZXingQtReader.h)
    target_link_libraries(ManagerAppQtCamReader ZXing::ZXing Qt::Gui Qt::Multimedia Qt::Quick)
    set_target_properties(ManagerAppQtCamReader PROPERTIES
        # Doesn't work:
        #     INSTALL_RPATH @executable_path/../Frameworks
        # Not sure why, but
        # https://stackoverflow.com/questions/13656033/how-do-you-add-an-rpath-to-an-executable-in-cmake-on-build-not-install-on-osx#comment108016975_13662896
        # indicates that CMake doesn't set it for executables.
        # 1. So manually use 'install_name_tool' in install(SCRIPT).
        OUTPUT_NAME SonicScoutQRScanner)
    set(BundleName "SonicScoutQR") # Up to 15 characters
    set(Copyright "(c)2023 Archit Kumar, Keyush Attarde and Diskuv, Inc.")
    set(BundleId "com.diskuv.sonicscout.QRScanner")
    # CI systems typically provide some form of job ID as an
    # environment variable. This example works for gitlab, but
    # other CI systems are likely to be similar. When not run
    # under CI, this will leave BUILD_VERSION set to 0.
    set(BUILD_VERSION $ENV{CI_JOB_ID})
    if(BUILD_VERSION STREQUAL "")
        # This is a local build, not through CI system
        set(BUILD_VERSION 0)
    endif()    
    if(XCODE)
        set_target_properties(ManagerAppQtCamReader PROPERTIES
            # These XCode attributes will be part of the final Info.plist.
            # XCode will add its own attributes as well.
            # Per Professional CMake:
            # > An advantage of using these build settings is that Xcode uses some of them to populate other parts of its UI.
            # > Specifying the same settings directly in the Info.plist file will sometimes result in those other parts of the Xcode UI not being updated in the same way.
            # > CFBundleDisplayName and LSApplicationCategoryType are two examples of this.            
            XCODE_ATTRIBUTE_PRODUCT_NAME              "${BundleName}"
            XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "${BundleId}"
            XCODE_ATTRIBUTE_MARKETING_VERSION         "${PROJECT_VERSION}"
            XCODE_ATTRIBUTE_CURRENT_PROJECT_VERSION   "${BUILD_VERSION}"
            XCODE_ATTRIBUTE_GENERATE_INFOPLIST_FILE   YES
            # This file is the initial Info.plist.
            XCODE_ATTRIBUTE_INFOPLIST_FILE            "${CMAKE_CURRENT_LIST_DIR}/Info.xcode.plist"
            XCODE_ATTRIBUTE_INFOPLIST_KEY_CFBundleDisplayName       "Sonic Scout QR Scanner"
            XCODE_ATTRIBUTE_INFOPLIST_KEY_LSApplicationCategoryType "public.app-category.educational-games"
            XCODE_ATTRIBUTE_INFOPLIST_KEY_NSPrincipalClass          "NSApplication"
            XCODE_ATTRIBUTE_INFOPLIST_KEY_NSHumanReadableCopyright  "${Copyright}")
    else()
        set_target_properties(ManagerAppQtCamReader PROPERTIES
            MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_LIST_DIR}/Info.not-xcode.in.plist"
            MACOSX_BUNDLE_BUNDLE_NAME "${BundleName}"
            MACOSX_BUNDLE_BUNDLE_VERSION "${BUILD_VERSION}"
            MACOSX_BUNDLE_COPYRIGHT "${Copyright}"
            MACOSX_BUNDLE_GUI_IDENTIFIER "${BundleId}"
            MACOSX_BUNDLE_LONG_VERSION_STRING "${PROJECT_VERSION}"
            MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION}")
    endif()
    install(TARGETS ManagerAppQtCamReader
        DESTINATION ${CMAKE_INSTALL_BINDIR}
        BUNDLE DESTINATION .)
    # Confer: dksdk-coder/packaging and dksdk-coder/docs/DISTRIBUTION.md for codesigning
    # * [codesign --options runtime] which is [-hardened-runtime]
    # * [codesign --timestamp] which is [-timestamp]
    # * signid=3F06C7CD5BC2C3C8FCAD07F2F38D55C43B2B0673 which is [-codesign=]
    # * [notarytool] which is [-sign-for-notarization=] and it subsumes [-codesign=], [-timestamp] and [-hardened-runtime]
    set(deployScanner ${CMAKE_CURRENT_BINARY_DIR}/SonicScoutQRScanner-$<CONFIG>.cmake)
    if(APPLE)
        find_program(MACDEPLOYQT_EXECUTABLE macdeployqt HINTS "${qmake_BIN}" REQUIRED)
        file(GENERATE OUTPUT "${deployScanner}" CONTENT "
            set(deployqt_ARGS)
            if(\"\$ENV{SCOUT_NOTARIZE}\" EQUAL 1)
                list(APPEND deployqt_ARGS
                    -sign-for-notarization=3F06C7CD5BC2C3C8FCAD07F2F38D55C43B2B0673)
                message(NOTICE \"Using notarization.\")
            else()
                list(APPEND deployqt_ARGS
                    -codesign=3F06C7CD5BC2C3C8FCAD07F2F38D55C43B2B0673)
            endif()
            if(\"\$ENV{SCOUT_VERBOSE}\" EQUAL 2)
                list(APPEND deployqt_ARGS
                    -verbose=2)
                message(NOTICE \"Using verbose logging.\")
            endif()

            execute_process(
                WORKING_DIRECTORY \"\${CMAKE_INSTALL_PREFIX}\"
                COMMAND
                    install_name_tool
                        -add_rpath @executable_path/../Frameworks
                        SonicScoutQRScanner.app/Contents/MacOS/SonicScoutQRScanner
                COMMAND
                    \"${MACDEPLOYQT_EXECUTABLE}\"
                        SonicScoutQRScanner.app
                        \"-qmldir=${CMAKE_CURRENT_LIST_DIR}\"                        
                        \${deployqt_ARGS}
                COMMAND_ECHO STDOUT
                COMMAND_ERROR_IS_FATAL ANY
            )

            if(\"\$ENV{SCOUT_NOTARIZE}\" EQUAL 1)
                execute_process(
                    WORKING_DIRECTORY \"\${CMAKE_INSTALL_PREFIX}\"
                    COMMAND
                        /bin/sh
                        \"${CMAKE_CURRENT_LIST_DIR}/notarize-macos.sh\"
                            \"${PROJECT_SOURCE_DIR}\"
                            \"\${CMAKE_INSTALL_PREFIX}/SonicScoutQRScanner.app\"
                            3F06C7CD5BC2C3C8FCAD07F2F38D55C43B2B0673
                            \"${CMAKE_OSX_ARCHITECTURES}\"
                    COMMAND_ECHO STDOUT
                    COMMAND_ERROR_IS_FATAL ANY
                )
            endif()
        ")
        install(SCRIPT "${deployScanner}")
    elseif(WIN32)
        find_program(WINDEPLOYQT_EXECUTABLE windeployqt HINTS "${qmake_BIN}" REQUIRED)
        file(GENERATE OUTPUT "${deployScanner}" CONTENT "
            set(deployqt_ARGS)
            if(\"\$ENV{SCOUT_VERBOSE}\" EQUAL 2)
                list(APPEND deployqt_ARGS --verbose 2)
                message(NOTICE \"Using verbose logging.\")
            endif()
            execute_process(
                WORKING_DIRECTORY \"\${CMAKE_INSTALL_PREFIX}\"
                COMMAND
                    \"${WINDEPLOYQT_EXECUTABLE}\"
                        # Source: $<TARGET_FILE:ManagerAppQtCamReader>
                        bin/SonicScoutQRScanner.exe
                        --release
                        --qmldir \"${CMAKE_CURRENT_LIST_DIR}\"
                        \${deployqt_ARGS}
                COMMAND_ECHO STDOUT
                COMMAND_ERROR_IS_FATAL ANY
            )
        ")
        install(SCRIPT "${deployScanner}")
        # Add shortcut for [Sonic Scout QR Scanner]. Only works for WIX packager
        set_property(
            INSTALL
                bin/SonicScoutQRScanner.exe
            PROPERTY
                CPACK_START_MENU_SHORTCUTS
                    "Sonic Scout QR Scanner"
        )    
    endif()
endif()

# ~~~ ADDITIONS
add_custom_target(ManagerApp_ALL)
add_dependencies(ManagerApp_ALL ManagerAppReader)
target_link_libraries(ManagerAppReader
    SquirrelScout::ManagerApp_c SquirrelScout::ManagerApp_ml
    # required for executables that embed OCaml
    DkSDK::OCaml::ForStaticBinary)
if (TARGET Qt::Gui)
    add_dependencies(ManagerApp_ALL ManagerAppQtReader)
    target_link_libraries(ManagerAppQtReader
        SquirrelScout::ManagerApp_c SquirrelScout::ManagerApp_ml
        # for caml_c_thread_register()
        DkSDK::OCaml::Compile
        # required for executables that embed OCaml
        DkSDK::OCaml::ForStaticBinary)
endif()
if (TARGET Qt::Multimedia AND TARGET Qt::Quick)
    add_dependencies(ManagerApp_ALL ManagerAppQtCamReader)
    target_link_libraries(ManagerAppQtCamReader
        SquirrelScout::ManagerApp_c SquirrelScout::ManagerApp_ml
        # for caml_c_thread_register()
        DkSDK::OCaml::Compile
        # required for executables that embed OCaml
        DkSDK::OCaml::ForStaticBinary)
endif()

list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")
