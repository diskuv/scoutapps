# Development

- [Development](#development)
  - [Qt 5 GUI](#qt-5-gui)
    - [Windows](#windows)
    - [Debian Linux](#debian-linux)
    - [Ubuntu Linux](#ubuntu-linux)
    - [WSL2](#wsl2)

## Qt 5 GUI

Qt 5 is a framework that needs to be pre-installed before building Squirrel Scout.

Qt 6 may work, but only Qt 5 is tested.

### Windows

Download and install Miniconda if you do not have Anaconda or Miniconda (Python) already.

In PowerShell:

```powershell
if ($LASTEXITCODE) {
  &conda env create -f dependencies/zxing/environment.yml
} else {
  &conda env update -f dependencies/zxing/environment.yml
}

conda run -n aqt aqt install-qt windows desktop 5.15.2 win64_msvc2019_64 -m all
```

### Debian Linux

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

### Ubuntu Linux

> Untested. Follow same Advanced steps as Debian

```sh
sudo apt install qt5-default
```

### WSL2

In addition to following the [Debian Linux](#debian-linux) or
[Ubuntu Linux](#ubuntu-linux) instructions, you will need
a video device. WSL2 will not forward your Windows camera.

Follow the instructions at https://github.com/PINTO0309/wsl2_linux_kernel_usbcam_enable_conf.
Or just settle for using a single test image.
