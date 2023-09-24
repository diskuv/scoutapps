# Development

- [Development](#development)
  - [Quick Links](#quick-links)
  - [Qt 5 GUI](#qt-5-gui)
    - [Qt on Windows](#qt-on-windows)
    - [Qt on Debian Linux](#qt-on-debian-linux)
    - [Qt on Ubuntu Linux](#qt-on-ubuntu-linux)
    - [Qt on WSL2](#qt-on-wsl2)
  - [Visual Studio Code](#visual-studio-code)
    - [VS Code on all Platforms](#vs-code-on-all-platforms)
    - [VS Code on Windows](#vs-code-on-windows)
  - [CMake](#cmake)
    - [CMake on Windows](#cmake-on-windows)
    - [CMakeUserPresets.json](#cmakeuserpresetsjson)

## Quick Links

Windows:

- Start with [Qt on Windows](#qt-on-windows)
- Then [CMake on Windows](#cmake-on-windows)
- Then [VS Code on Windows](#vs-code-on-windows)
- Then [VS Code on All Platforms](#vs-code-on-all-platforms)
- Then [CMakeUserPresets.json](#cmakeuserpresetsjson). Select the `windows_x86_64 (debug)` CMake preset.
- Then in CMake build the `ManagerAppQtCamReader` target.
  > If you use WSL2 which doesn't have access to the Windows camera device, build the `ManagerAppReader` target instead.
  > Once the target is built, you can do:
  >
  > ```powershell
  > build_dev\src\ManagerApp\ManagerAppReader.exe -fast -format -qrcode tests\Units\ManagerApp\qrcode-7\01-01.png
  > ```

- If you run `ManagerAppQtCamReader` from the command line, remember the PATH instructions in [Qt on Windows](#qt-on-windows)

Ubuntu:

- Start with [Qt on Ubuntu Linux](#qt-on-ubuntu-linux)
- Then [VS Code on All Platforms](#vs-code-on-all-platforms)
- Then [CMakeUserPresets.json](#cmakeuserpresetsjson). Select the `linux_x86_64 (debug)` CMake preset.
- Then in CMake build the `ManagerAppQtCamReader` target
  ```sh
  build_dev/src/ManagerApp/ManagerAppReader -fast -format -qrcode tests/Units/ManagerApp/qrcode-7/01-01.png
  ```

Debian:

- Start with [Qt on Debian Linux](#qt-on-debian-linux)
- Then [VS Code on All Platforms](#vs-code-on-all-platforms)
- Then [CMakeUserPresets.json](#cmakeuserpresetsjson). Select the `linux_x86_64 (debug)` CMake preset.
- Then in CMake build the `ManagerAppQtCamReader` target. If you use WSL2 which doesn't have access to the Windows camera device, build the `ManagerAppReader` target instead.

## Qt 5 GUI

Qt 5 is a framework that needs to be pre-installed before building Squirrel Scout.

Qt 6 may work, but only Qt 5 is tested.

### Qt on Windows

FIRST, for setup ...

Download and [install Miniconda](https://docs.conda.io/projects/miniconda/en/latest/miniconda-install.html)
if you do not have Anaconda or Miniconda (Python) already.

In PowerShell:

```powershell
if ($LASTEXITCODE) {
  &conda env create -f dependencies/zxing/environment.yml
} else {
  &conda env update -f dependencies/zxing/environment.yml
}

conda run -n aqt aqt install-qt windows desktop 5.15.2 win64_msvc2019_64 -m all
```

FINALLY, **anytime you run a Qt on Windows program like ManagerAppQtCamReader or ManagaerAppQtReader**
from the PowerShell you will need first to do the following from the project source code directory:

```powershell
$env:PATH += ";$PWD\5.15.2\msvc2019_64\bin"
```

or from Command Prompt you will need to do:

```dosbatch
set PATH=%PATH%;%CD%\5.15.2\msvc2019_64\bin
```

### Qt on Debian Linux

```sh
sudo apt install qtbase5-dev qtmultimedia5-dev qtdeclarative5-dev
sudo apt install qml-module-qtmultimedia qml-module-qtquick-controls2 qml-module-qtquick-layouts qml-module-qtquick-shapes qml-module-qtquick-window2
```

> *Advanced Only*. To search for specific Qt5 libraries that match
> [zxing-cpp-src](build_dev/_deps/zxing-cpp-src/example/CMakeLists.txt),
> do:
>
> ```sh
> sudo apt install apt-file
> sudo apt-file update
> apt-file search Qt5CoreConfig.cmake
> apt-file search Qt5GuiConfig.cmake
> apt-file search Qt5MultimediaConfig.cmake
> apt-file search Qt5QuickConfig.cmake
> apt-file search QtMultimedia/qmldir
> apt-file search QtQuick/Controls -l
> apt-file search QtQuick/Layouts -l
> apt-file search QtQuick/Shapes -l
> apt-file search QtQuick/Window -l
> ```

### Qt on Ubuntu Linux

> Untested. Follow same Advanced steps as Debian

```sh
sudo apt install qt5-default
```

### Qt on WSL2

In addition to following the [Qt on Debian Linux](#qt-on-debian-linux) or
[Qt on Ubuntu Linux](#qt-on-ubuntu-linux) instructions, you will need
a video device. WSL2 will not forward your Windows camera.

Follow the instructions at <https://github.com/PINTO0309/wsl2_linux_kernel_usbcam_enable_conf>.
Or just settle for using a single test image.

## Visual Studio Code

### VS Code on all Platforms

When Visual Studio Code prompts you to install the **Workspace Recommendations**, do it!

### VS Code on Windows

You **must** run Visual Studio Code using `with-dkml env -u HOME code` on Windows
if you are using this Squirrel Scout project. You may need to exit your Visual Studio Code
if you haven't done so.

The simplest way to run Visual Studio Code correctly:

- use the Run Command (⊞ Win + R) and then type `with-dkml env -u HOME code`.
- After the first time, you can use the Run Command (⊞ Win + R) and press the
  Up Arrow (↑) until you see `with-dkml env -u HOME code`.

## CMake

### CMake on Windows

FIRST, download [Ninja-win.zip](https://github.com/ninja-build/ninja/releases),
and then extract it somewhere. We'll assume you extracted it to `C:\`, so you
will end up with:

```text
C:\
└── ninja.exe
```

SECOND, use "Edit environment variables for your account" in your Control
Panel to add a User Environment Variable `DKSDK_NINJA_PROGRAM` with the
value `C:\ninja.exe`.

THIRD, download and install the CMake [Windows x64 Installer](https://cmake.org/download/)

### CMakeUserPresets.json

When you initially `git clone` the project, you will not have the
`CMakeUserPresets.json` file:

```text
.
├── .gitignore
├── CMakeLists.txt
├── CMakePresets.json
├── CMakeUserPresets.json            <-- Will not exist
├── CMakeUserPresets-SUGGESTED.json
...
```

You should copy the contents of `CMakeUserPresets-SUGGESTED.json` into
`CMakeUserPresets.json`.

> The `CMakeUserPresets.json` is ignored on purpose by Git! You can't
> check in changes to it because it is **meant for you to edit**
> so suit your own development desktop configuration.
> That also means you have to create `CMakeUserPresets.json` yourself.
