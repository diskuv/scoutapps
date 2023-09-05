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

# Qt library
if(MSVC AND IS_DIRECTORY ${PROJECT_SOURCE_DIR}/5.15.2/msvc2019_64/lib/cmake/Qt5 AND NOT Qt5_DIR)
    set(Qt5_DIR ${PROJECT_SOURCE_DIR}/5.15.2/msvc2019_64/lib/cmake/Qt5 CACHE FILEPATH "Qt5 installation directory")
endif()

# ------
# The OCaml code
# ------

add_library(ManagerApp_ml STATIC ManagerApp_ml.ml)
add_library(SquirrelScout::ManagerApp_ml ALIAS ManagerApp_ml)

# ------
# The C code that calls OCaml
# ------

add_library(ManagerApp_c STATIC squirrel_scout_manager.c)
add_library(SquirrelScout::ManagerApp_c ALIAS ManagerApp_c)
target_link_libraries(ManagerApp_c
    PRIVATE DkSDK::OCamlCompile
    PUBLIC Threads::Threads DkSDK::OCamlDependencies)
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

install(TARGETS ManagerAppReader DESTINATION ${CMAKE_INSTALL_BINDIR})

find_package(Qt5 COMPONENTS Gui Multimedia Quick QUIET)
if (NOT (Qt5_FOUND OR Qt6_FOUND))
    message("INFO: Qt (Gui/Multimedia/Quick) not found, skipping Qt examples")
endif()

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

if (TARGET Qt::Gui)
    add_executable (ManagerAppQtReader ZXingQtReader.cpp ZXingQtReader.h)
    target_link_libraries(ManagerAppQtReader ZXing::ZXing Qt::Gui)
endif()

if (TARGET Qt::Multimedia AND TARGET Qt::Quick)
    add_executable(ManagerAppQtCamReader ZXingQtCamReader.cpp ZXingQtCamReader.qrc ZXingQtReader.h)
    target_link_libraries(ManagerAppQtCamReader ZXing::ZXing Qt::Gui Qt::Multimedia Qt::Quick)
endif()

# ~~~ ADDITIONS
target_link_libraries(ManagerAppReader SquirrelScout::ManagerApp_c SquirrelScout::ManagerApp_ml)
if (TARGET Qt::Gui)
    target_link_libraries(ManagerAppQtReader SquirrelScout::ManagerApp_c SquirrelScout::ManagerApp_ml)
    if(WIN32 AND Qt5_DIR)
        add_custom_command( # Easy testing in build dir (but cmake install is preferred)
            TARGET ManagerAppQtReader POST_BUILD
            COMMAND "${CMAKE_COMMAND}" -E chdir "${Qt5_DIR}/../../../bin" "${CMAKE_COMMAND}" -E copy
                Qt5Cored.dll Qt5Guid.dll
                "$<TARGET_FILE_DIR:ManagerAppQtReader>"
            VERBATIM)
    endif()
endif()
if (TARGET Qt::Multimedia AND TARGET Qt::Quick)
    target_link_libraries(ManagerAppQtCamReader SquirrelScout::ManagerApp_c SquirrelScout::ManagerApp_ml)
    if(WIN32 AND Qt5_DIR)
        add_custom_command( # Easy testing in build dir (but cmake install is preferred)
            TARGET ManagerAppQtCamReader POST_BUILD
            COMMAND "${CMAKE_COMMAND}" -E chdir "${Qt5_DIR}/../../../bin" "${CMAKE_COMMAND}" -E copy
                Qt5Cored.dll Qt5Guid.dll Qt5Networkd.dll Qt5Multimediad.dll Qt5Qmld.dll
                "$<TARGET_FILE_DIR:ManagerAppQtCamReader>"
            VERBATIM)
    endif()
endif()

list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")
