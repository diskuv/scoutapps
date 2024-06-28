# macOS

Run the SonicScoutQRScanner:

```sh
install_name_tool -add_rpath @executable_path/../../../../../../5.15.2/clang_64/lib build_dev/src/ManagerApp/SonicScoutQRScanner.app/Contents/MacOS/SonicScoutQRScanner

build_dev/src/ManagerApp/SonicScoutQRScanner.app/Contents/MacOS/SonicScoutQRScanner
```

Run the sonic-scout-cli:

```sh
build_dev/src/MainCLI/sonic-scout-cli status
```
