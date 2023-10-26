# Squirrel Scout - OCaml Backend

> DO NOT RELEASE UNTIL ALL `RELEASE_BLOCKER` COMMENTS HAVE BEEN REMOVED.

[DkSDK CMake]: https://diskuv.com/cmake/help/latest/

> A simple Hello World example that demonstrates how to use
> [DkSDK CMake]

## Introduction

Start with [DkSDK CMake] to understand what the SDK can do for you.

Once you have become a [DkSDK CMake] subscriber, skip down to
the [Quick Start](#quick-start) to build and run this project.

Finally, you can access the auto-generated intermediate
and advanced documentation for this project at [DkSDK.md](./DkSDK.md).

*This README is where you would customize the documentation for your
own project and team.*

## Quick Start

### First Steps

```sh
rm -rf _dn build build_dev
sh ci/git-clone.sh -l
./dk dksdk.vscode.ocaml.configure
```

You will want to start with the following targets in your IDE:

1. `DkSDK_DevTools`
2. `DkSDKTest_UnitTests_ALL`
3. `main-cli` in `src/MainCLI`

or do it from the **Linux**, **WSL2 Debian** or **WSL2 Ubuntu** command line:

```sh
./dk dksdk.cmake.link QUIET
cp CMakeUserPresets-SUGGESTED.json CMakeUserPresets.json
.ci/cmake/bin/cmake --preset dev-Linux-x86_64
.ci/cmake/bin/cmake --build build_dev --target main-cli DkSDK_DevTools DkSDKTest_UnitTests_ALL ManagerApp_ALL
```

or do it from the **Windows with DkML** command line:

```powershell
./dk dksdk.cmake.link QUIET
with-dkml cp CMakeUserPresets-SUGGESTED.json CMakeUserPresets.json
with-dkml .ci/cmake/bin/cmake --preset dev-Windows64
with-dkml .ci/cmake/bin/cmake --build build_dev --target main-cli DkSDK_DevTools DkSDKTest_UnitTests_ALL ManagerApp_ALL
```

## Launching Manager App

### Manager App on Windows

First make sure you have followed [Development > Qt 5 Gui > Qt on Windows](./DEVELOPMENT.md#qt-on-windows).

Then you can run the Manager App using:

```sh
.ci/cmake/bin/cmake -E env --modify PATH=path_list_prepend:5.15.2/msvc2019_64/bin --modify OCAMLRUNPARAM=set:b -- build_dev/src/ManagerApp/ManagerAppQtCamReader -- build_dev/test.db
```

## Tutorial

### Manipulating Data

FIRST, start by deleting any `example.db` you see in your project folder (the same
folder as this).

SECOND, run the following to see an `example.db` database get created
but without any content:

```sh
build_dev/src/MainCLI/main-cli status           -d example.db
build_dev/src/MainCLI/main-cli matches-for-team -d example.db 1318
build_dev/src/MainCLI/main-cli matches-for-team -d example.db 5588
build_dev/src/MainCLI/main-cli matches-for-team -d example.db 949
build_dev/src/MainCLI/main-cli match-schedule   -d example.db
```

THIRD, load in some scheduled match data:

```sh
build_dev/src/MainCLI/main-cli insert-scheduled-matches -d example.db --match-json data/schedule.json
```

FOURTH, when we look at the data everything except `status` has information:

```sh
build_dev/src/MainCLI/main-cli status           -d example.db
build_dev/src/MainCLI/main-cli matches-for-team -d example.db 1318
build_dev/src/MainCLI/main-cli matches-for-team -d example.db 5588
build_dev/src/MainCLI/main-cli matches-for-team -d example.db 949
build_dev/src/MainCLI/main-cli match-schedule   -d example.db
```

FIFTH, because there is some hard-coded data that has not been cleaned
up. You need to insert it until the hard-coding is fixed, and then
you will be able to see the `status`:

```sh
build_dev/src/MainCLI/main-cli insert-raw-match-test-data -d example.db
build_dev/src/MainCLI/main-cli status                     -d example.db
```

### Building for Android

You will need to be on Linux, WSL2 on Windows, or macOS for this step.

The preset will be `ci-linux_x86_64_X_android_arm64v8a` if you are
building for the actual device, and `ci-linux_x86_64_X_android_x86_64` if
you are building for the emulator.

```sh
rm -rf build fetch _dn

./dk dksdk.cmake.link
./dk dksdk.android.ndk.download NO_SYSTEM_PATH
sh ci/git-clone.sh -l
sh ci/git-clone.sh -p .ci/cmake/bin/cmake
#   Use ci-linux_x86_64_X_android_arm64v8a for the real Android device.
#   Use ci-linux_x86_64_X_android_x86_64 for the Android Emulator.
.ci/cmake/bin/cmake --preset ci-linux_x86_64_X_android_x86_64
.ci/cmake/bin/cmake --build --preset ci-objs
```

That will produce `build/src/ObjsLib/libSquirrelScout_ObjsLib.a` which
can be copied to the Android project.
