add_test(NAME ManagerAppReaderTest COMMAND ManagerAppReader -fast -format qrcode "${CMAKE_CURRENT_LIST_DIR}/qrcode-generated/test_qr.png" -- test.db)

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
            PATH=path_list_prepend:${QTDIR}
            # Add OCaml backtrace if an exception is thrown
            OCAMLRUNPARAM=set:b)
    endif()
endfunction()

# The 01-01.png test should not longer work. It was a text QR code that is not compliant
# with a capnp schema.
#       add_qt_test(NAME ManagerAppQtReaderTest-01-01
#           COMMAND ManagerAppQtReader "${CMAKE_CURRENT_LIST_DIR}/qrcode-7/01-01.png" -- 01-01.db)
add_qt_test(NAME ManagerAppQtReaderTest-test_qr
    COMMAND ManagerAppQtReader "${CMAKE_CURRENT_LIST_DIR}/qrcode-generated/test_qr.png" -- test_qr.db)
add_qt_test(NAME ManagerAppQtReaderTest-Screenshot_2023-10-24
    COMMAND ManagerAppQtReader "${CMAKE_CURRENT_LIST_DIR}/qrcode-app/Screenshot_2023-10-24-12-19-42-565.jpeg" -- Screenshot_2023-10-24-12-19-42-565.db)
add_qt_test(NAME ManagerAppQtReaderTest-Screenshot_2024-02-27
    COMMAND ManagerAppQtReader "${CMAKE_CURRENT_LIST_DIR}/qrcode-app/Screenshot_2024-02-27.jpg" -- Screenshot_2024-02-27.db)
    
add_qt_test(NAME ManagerAppQtCamReaderTest COMMAND ManagerAppQtCamReader -- test.db)
