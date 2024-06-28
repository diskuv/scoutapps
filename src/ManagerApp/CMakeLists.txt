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
find_program(WINDEPLOYQT_EXECUTABLE windeployqt HINTS "${qmake_BIN}")
find_program(MACDEPLOYQT_EXECUTABLE macdeployqt HINTS "${qmake_BIN}")

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

    add_executable(ManagerAppQtCamReader MACOSX_BUNDLE WIN32 ZXingQtCamReader.cpp ZXingQtCamReader.qrc ZXingQtReader.h)
    target_link_libraries(ManagerAppQtCamReader ZXing::ZXing Qt::Gui Qt::Multimedia Qt::Quick)
    set_target_properties(ManagerAppQtCamReader PROPERTIES
        # Doesn't work:
        #     INSTALL_RPATH @executable_path/../Frameworks
        # Not sure why, but
        # https://stackoverflow.com/questions/13656033/how-do-you-add-an-rpath-to-an-executable-in-cmake-on-build-not-install-on-osx#comment108016975_13662896
        # indicates that CMake doesn't set it for executables.
        # 1. So manually use 'install_name_tool' in install(SCRIPT).
        OUTPUT_NAME SonicScoutQRScanner)
    install(TARGETS ManagerAppQtCamReader
        DESTINATION ${CMAKE_INSTALL_BINDIR}
        BUNDLE DESTINATION .)
    # Confer: dksdk-coder/packaging and dksdk-coder/docs/DISTRIBUTION.md for codesigning
    # * [codesign --options runtime] which is [-hardened-runtime]
    # * [codesign --timestamp] which is [-timestamp]
    # * signid=3F06C7CD5BC2C3C8FCAD07F2F38D55C43B2B0673 which is [-codesign=]
    # * [notarytool] which is [-sign-for-notarization=] and it subsumes [-codesign=], [-timestamp] and [-hardened-runtime]
    if(APPLE)
        set(deployScanner ${CMAKE_CURRENT_BINARY_DIR}/SonicScoutQRScanner-$<CONFIG>.cmake)
        file(GENERATE OUTPUT "${deployScanner}" CONTENT "
            if(\$ENV{SCOUT_NOTARIZE} EQUAL 1)
                set(deployqt_ARGS -sign-for-notarization=3F06C7CD5BC2C3C8FCAD07F2F38D55C43B2B0673)
                message(NOTICE \"Using notarization.\")
            else()
                set(deployqt_ARGS -codesign=3F06C7CD5BC2C3C8FCAD07F2F38D55C43B2B0673)
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
                        -verbose=1
                        \"-qmldir=${CMAKE_CURRENT_LIST_DIR}\"
                        -dmg
                        ${deployqt_ARGS}
                COMMAND_ERROR_IS_FATAL ANY
            )
        ")
        install(SCRIPT "${deployScanner}")
    endif()
endif()

# ~~~ ADDITIONS
add_custom_target(ManagerApp_ALL)
add_dependencies(ManagerApp_ALL ManagerAppReader)
target_link_libraries(ManagerAppReader
    SquirrelScout::ManagerApp_c SquirrelScout::ManagerApp_ml)
if (TARGET Qt::Gui)
    add_dependencies(ManagerApp_ALL ManagerAppQtReader)
    target_link_libraries(ManagerAppQtReader
        SquirrelScout::ManagerApp_c SquirrelScout::ManagerApp_ml
        # for caml_c_thread_register()
        DkSDK::OCaml::Compile)
endif()
if (TARGET Qt::Multimedia AND TARGET Qt::Quick)
    add_dependencies(ManagerApp_ALL ManagerAppQtCamReader)
    target_link_libraries(ManagerAppQtCamReader
        SquirrelScout::ManagerApp_c SquirrelScout::ManagerApp_ml
        # for caml_c_thread_register()
        DkSDK::OCaml::Compile)
endif()

list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")
