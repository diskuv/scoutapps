add_test(NAME ManagerAppReaderTest COMMAND ManagerAppReader -fast -format qrcode "${CMAKE_CURRENT_LIST_DIR}/qrcode-7/test_qr.png" -- test.db)

# Find QTDIR
set(QTDIR)
find_package(Qt5 COMPONENTS Gui Multimedia Quick QUIET)
if(Qt6_DIR AND Qt6_FOUND)
    set(QTDIR "${Qt6_DIR}/../../../bin")
    cmake_path(NORMAL_PATH QTDIR)
elseif(Qt5_DIR AND Qt5_FOUND)
    set(QTDIR "${Qt5_DIR}/../../../bin")
    cmake_path(NORMAL_PATH QTDIR)
endif()

function(add_qt_test)
    set(noValues)
    set(singleValues NAME)
    set(multiValues COMMAND)
    cmake_parse_arguments(PARSE_ARGV 0 ARG "${noValues}" "${singleValues}" "${multiValues}")

    add_test(NAME ${ARG_NAME} COMMAND ${ARG_COMMAND})

    # Ensure the required Qt DLLs can be found at runtime, and Qt can use the
    # .dll location ("QTDIR") to find where its plugins are.
    # We only need it for Windows, but for consistency we'll do it on all OS-es.
    # Confer: https://doc.qt.io/qt-6/deployment-plugins.html
    if (QTDIR)
        set_property(TEST ${ARG_NAME} APPEND PROPERTY
            ENVIRONMENT_MODIFICATION
            PATH=path_list_prepend:${QTDIR})
    endif()
endfunction()

add_qt_test(NAME ManagerAppQtReaderTest COMMAND ManagerAppQtReader "${CMAKE_CURRENT_LIST_DIR}/qrcode-7/01-01.png" -- test.db)
add_qt_test(NAME ManagerAppQtCamReaderTest COMMAND ManagerAppQtCamReader -- test.db)
