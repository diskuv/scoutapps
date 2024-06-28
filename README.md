# Sonic Scout Backend

> DO NOT WIDELY RELEASE UNTIL ALL `RELEASE_BLOCKER` COMMENTS HAVE BEEN REMOVED.

## Quick Start

### First Steps

```sh
rm -rf build build_dev
./dk dksdk.project.get
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
./dk dksdk.project.get
#   Use ci-linux_x86_64_X_android_arm64v8a for the real Android device.
#   Use ci-linux_x86_64_X_android_x86_64 for the Android Emulator.
.ci/cmake/bin/cmake --preset ci-linux_x86_64_X_android_x86_64
.ci/cmake/bin/cmake --build --preset ci-objs
```

That will produce `build/src/ObjsLib/libSquirrelScout_ObjsLib.a` which
can be copied to the Android project.

## Licensing

The source code of `Sonic Scout Backend` is in the `src/`, `tests/` and `dependencies/` folders are available
under the open source [OSL 3.0 license](./LICENSE-OSL3).

A guide to the Open Software License version 3.0 (OSL 3.0) is available at
<https://rosenlaw.com/OSL3.0-explained.htm>.

The `dk`, `dk.cmd` and `__dk.cmake` build tools are [OSL 3.0 licensed](./LICENSE-OSL3)
with prompts for additional licenses for the [LGPL 2.1 with an OCaml static linking exception](./LICENSE-LGPL21-ocaml) and the [DkSDK SOFTWARE DEVELOPMENT KIT LICENSE AGREEMENT](./LICENSE-DKSDK).

The QR scanning app uses Qt5 which has a [LGPL 3.0 license](https://doc.qt.io/qt-5/licensing.html).

A DkSDK license token is necessary when you want to rebuild the applications with
customizations for your own robotics team. The token is free to any First Robotics team
who has an adult sponsor (ex. a mentor) who also agrees to submit their team's code changes at the end of each robotics season (a "pull request") using an open-source
[Contributor License Agreement](https://yahoo.github.io/oss-guide/docs/resources/what-is-cla.html).
Contact jonah AT diskuv.com to get a token.

You do *not* need a token to run the QR scanner backend app.

The copyright is owned jointly by:

- Archit Kumar
- Keyush Attarde
- Diskuv, Inc.
