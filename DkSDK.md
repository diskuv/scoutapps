# DkSDK

> Recommendation: Place this file in source control.
>
> Auto-generated documentation by `./dk dksdk.project.new` of SquirrelScout.

## Project Structure

### `src/`

In the `src/` directory we have subdirectories for:

* `HelloLib` - a simple library
* `MainCLI` - a command line interface (CLI) executable that uses the library

### `dependencies/`

The `dependencies/` contains all the instructions to download and build the third-party
dependencies.

## Installing

### Errata

Visit <https://diskuv.com/cmake/help/latest/guide/releases> for the latest list of
known issues ("Errata") and how to fix them.

Email support AT diskuv.com if you encounter unreported issues.

### Build Host - Windows Subsystem for Linux 2 (WSL2)

#### Setup WSL2

You will need WSL2 on your Windows system before you can follow this
section. Typically it is just running `wsl --install` in an Administrative
Command Prompt or PowerShell. If that does not work, full instructions
are available at <https://learn.microsoft.com/en-us/windows/wsl/install>.

When you run the commands below, you may be asked to:

* Setup a UNIX username and password. This will be used to create a login
  for a new Debian Linux installation of WSL2. Do not re-use your Windows
  password. If you already have Debian, it will not be re-installed.
* Told about `Running command: sudo ...` and asked for your password. This
  will be your **Debian Linux (WSL2)** password, not your Windows password.

In Powershell or Command Prompt, run the following command:

```shell
.\ci\wsl2-setup.cmd

wsl -d Debian ./dk user.dev.gcm.install
wsl -d Debian git config --global credential.credentialStore secretservice

# You do not have to clone the source code to ~/source. But you must make sure to
# use a directory that is on a native Linux filesystem. If you don't know what
# that means, just use the commands below!
install -d ~/source
git -C ~/source clone https://gitlab.com/diskuv/samples/SquirrelScout.git
```

#### Setup WSL2 Graphics and IDEs

1. Follow <https://learn.microsoft.com/en-us/windows/wsl/tutorials/gui-apps#install-support-for-linux-gui-apps>
2. Follow <https://wslutiliti.es/wslu/install.html#debian> in a `wsl -d Debian` login. Use the Debian 11 instructions.

Using CLion?

* In Powershell or Command Prompt, run the following command:

  ```shell
  wsl -d Debian ./dk user.dev.clion.install
  ```

#### Android NDK x86_64 on WSL2

```shell
sh ci/download-build-tools.sh linux_x86_64 linux_x86_64-android_x86_64 .ci/local
sh ci/git-clone.sh -p .ci/local/bin/cmake

# Do configure with CMake 3.25.2 to avoid https://discourse.cmake.org/t/cmake-exception/2240/2
# with CLion's 3.24.
/opt/diskuv/usr/share/dktool/cmake-3.25.2/bin/cmake --preset=ci-linux_x86_64_X_android_x86_64

# Using CLion?
./dk user.dev.clion.run
# After running CLion:
# 1. Go to Settings > Build, Execution, Deployment > CMake and disable _all_ the profiles.
# 2. Delete the `build/`, `_dn/` and `_build/` directories if present.
# 3. Go to Settings > Build, Execution, Deployment > CMake and enable the `linux_x86_X_android_x86_64` profile.

```

#### Android NDK arm32-v7a on WSL2

```shell
sh ci/download-build-tools.sh linux_x86 linux_x86_64-android_arm32v7a .ci/local
sh ci/git-clone.sh -p .ci/local/bin/cmake

# Do configure with CMake 3.25.2 to avoid https://discourse.cmake.org/t/cmake-exception/2240/2
# with CLion's 3.24.
/opt/diskuv/usr/share/dktool/cmake-3.25.2/bin/cmake --preset=ci-linux_x86_X_android_arm32v7a

# Using CLion?
./dk user.dev.clion.run
# After running CLion:
# 1. Go to Settings > Build, Execution, Deployment > CMake and disable _all_ the profiles.
# 2. Delete the `build/`, `_dn/` and `_build/` directories if present.
# 3. Go to Settings > Build, Execution, Deployment > CMake and enable the `linux_x86_X_android_arm32v7a` profile.
```

### Build Host - Native Windows

You will need either DkML installed or a MSYS2 installation.

* There is nothing to do if you have DkML installed. It has an embedded MSYS2
  installation that will be re-used for DkSDK.
* If you have a standalone MSYS2 installation, you must set the CMake variable [`DKSDK_MSYS2_DIR`](#dksdk_msys2_dir).

#### Building with Command Prompt on Windows

The Ninja generator, used in `CMakePresets.json` and recommended by
[Microsoft](https://learn.microsoft.com/en-us/cpp/build/cmake-presets-vs?view=msvc-170), needs
to be "external"-ly setup. That means you run `vcvarsall.bat` before running CMake.

You will need to have selected:

* The architecture `x86` or `x64`. Be aware that Ninja uses `x86` for 32-bit, while Visual Studio traditionally
  has used `Win32`.
* The VC version 14.25 or 14.26
* The Windows SDK version 10.0.18362.0

For example, using the Command Prompt (not Powershell!):

```shell
vcvarsall.bat x64 10.0.18362.0 -vcvars_ver=14.26
cmake --preset THE_PRESET
cmake --build --preset THE_BUILD_PRESET
```

#### Building with CLion on Windows

In `Settings > Build, Execution, Deployment > CMake > Toolchains`, make sure there is at least one
"Visual Studio" toolchain that has a Toolset with:

* a directory that is a Visual Studio 2019 installation (also known as v142, or Version 16)
* has `-vcvars_ver=14.26` (or `-vcvars_ver=14.25`) in Version field

#### Android NDK arm64-v8a on Native Windows through WSL2

> This is usually very slow because there will be a slow link between the
> Windows filesystem and the Linux filesystem. Use at your own risk.

**Prerequisite**: [Setup WSL2](#setup-wsl2)

In Powershell or Command Prompt, run the following commands:

```shell
wsl -d Debian -- ci/download-build-tools.sh linux_x86_64 linux-android_x86_64 .ci/wsl2
wsl -d Debian
```

You will now be inside the WSL2 Debian installation with all of the SquirrelScout
source code available in the current directory. Run the following to build the source
code into the `build/` build directory:

```shell
export PATH="$PWD/.ci/wsl2/bin:$PATH"
export OPAMROOTISOK=1

cmake --version
> cmake version 3.25.2
>
> CMake suite maintained and supported by Kitware (kitware.com/cmake).

sh ci/exec.sh linux_x86_64 cmake --preset=wsl2-android_x86_64
sh ci/exec.sh linux_x86_64 cmake --build --preset=wsl2-linux_x86_64-main
sh ci/exec.sh linux_x86_64 ctest --preset=wsl2-linux_x86_64-test
```

### Build Host - Linux

There are over [600 active Linux distributions](https://truelist.co/blog/linux-statistics).

DkSDK supports:

* Debian "stable" is the supported "modern" Linux production server.
* Debian "stable" is the supported "modern" Linux build server.
* The latest Ubuntu LTS, which is derived from Debian, is the supported Linux developer desktop.
* Debian "stable-slim" is the supported "modern" Linux Docker container image.
* `manylinux_2_28` 2_28 is the supported "backwards-compatible, old GLIBC" Linux Docker container image.
  `glibc`-based `manylinux_2_28` is compatible with Linux distributions released _after_ 2018
  with the notable exception of Alpine. You may also see some support for
  `manylinux2014` which is compatible with most versions of most major distributions
  released _after_ 2014; however, Diskuv is actively deprecating `manylinux2014`.

#### Distributing DkSDK-produced binaries to your Linux customers

If and when you need to distribute your DkSDK-produced binaries to Linux customers, you would
use the "backwards-compatible, old GLIBC" Linux Docker container image. That way almost all Linux
distributions that your customers use will be supported.

This old GLIBC technique has been adopted from the Python community, where they use it to distribute
binary "wheels". An alternative approach from the Go community is to distribute statically linked
executables. **DkSDK does not support statically linked executables for two reasons:**

1. Statically linked executables are not conventional for OCaml (even though there are
[some hacky techniques](https://ocamlpro.com/blog/2021_09_02_generating_static_and_portable_executables_with_ocaml/)
to do static linking).
2. Static linking can violate LGPL/GPL and other restrictively licensed libraries.

#### Android NDK x86_64 on Linux

```shell
sh ci/git-clone.sh -l
sh ci/download-build-tools.sh linux_x86_64 linux-android_x86_64 .ci/local
```

Then use the `ci-linux_x86_64_X_android_x86_64` CMake profile in your favorite
CMake IDE.

### Build Host - macOS

#### Android NDK arm64-v8a on Apple Silicon

```shell
sh ci/git-clone.sh -l
sh ci/download-build-tools.sh darwin_arm64 macos-android_arm64v8a .ci/local
```

Then use the `ci-darwin_arm64_X_android_arm64v8a` CMake profile in your favorite
CMake IDE.

### Target - Android

You can compile this project's code by directly using Android NDK
or (TBD) using Android Studio.

Android NDK builds will use NDK r23 and target a minimum API of 21.

## CMake Variables

### CMAKE_VS_PLATFORM_TOOLSET_VERSION

Type: `STRING`

Applies to: Windows with Visual Studio compiler

What: This variable can be set to Visual Studio C version numbers like `14.25` or `14.26`.
These version numbers correspond to the Visual Studio components that can be seen
in the Visual Studio Installer like:

* `Microsoft.VisualStudio.Component.VC.14.25`
* `Microsoft.VisualStudio.Component.VC.14.26`

Only versions `14.25` and `14.26` are compatible with DkSDK.

When to use: If you have multiple Visual Studio installations, and some of those installations
are not compatible versions with DkSDK, this variable can let you tell DkSDK to pick a
compatible installation. The variable will be ignored, however, if you have
hardcoded the CMAKE_C_COMPILER cache variable.

### DKSDK_MSYS2_DIR

Type: `FILEPATH`

Applies to: Windows

What: Tells DkSDK to re-use the specified MSYS2 system. Without this variable, DkSDK locates and
expects the embedded MSYS2 system inside a pre-installed DkML.

When to use:

* If you don't want to install DkML, just install MSYS2 from its website and point
  the `DKSDK_MSYS2_DIR` directory to your newly installed MSYS2 system.
* Many CI services like GitHub Actions and GitLab CI already come bundled with MSYS2, or have
  easy ways to install MSYS2. If you are in CI, use this variable.

For example, `cmake -G Ninja -D DKSDK_MSYS2_DIR=msys64` if MSYS2 is installed in the subdirectory
`msys64` of the project source code, or `cmake -G Ninja -D DKSDK_MSYS2_DIR=C:\msys64` if installed
to `C:\msys64`.

### DKSDK_OPAM_ROOT

Type: `FILEPATH`

What: Tells DkSDK to use the specified opam root. Without this variable, DkSDK creates its own
opam root inside the CMake binary directory including somewhat time-consuming downloads of
the central opam repository.

When to use:

* The OCaml CI actions `setup-ocaml` and `setup-dkml` already provide an opam root. If you are using
  either of them, use this variable to save time.

For example, `cmake -G Ninja -D DKSDK_OPAM_ROOT=msys64` if the opam root is in the subdirectory
`.ci/o` under the project source code, or `cmake -G Ninja -D DKSDK_OPAM_ROOT=C:\opam` if the
opam root is `C:\opam`.

`DKSDK_OPAM_ROOT_USER` takes precedence over this variable.

### DKSDK_OPAM_ROOT_USER

Type: `BOOL`

What: Tells DkSDK to use the standard opam root on your machine. Without this variable, DkSDK creates its own
opam root inside the CMake binary directory including somewhat time-consuming downloads of
the central opam repository.

When to use:

* If you have already installed opam on your development machine and are fine with DkSDK switches being
  visible to other opam-aware processes on your machine (like Visual Studio Code with the OCaml Language Server),
  use this variable to save time.

This variable takes precedence over `DKSDK_OPAM_ROOT`.

### DKSDK_HOST_IMPRECISE_C99_FLOAT

Type: `BOOL`

What: Tells DkSDK that your host ABI (the build machine) does not support precise C99 float operations.

When to use: If your build machine is VirtualBox or some other emulator, and you see the error
`configure: error: C99 float ops unavailable, enable replacements with --enable-imprecise-c99-float-ops`,
then set this variable to `ON`.

## Troubleshooting

In the `ocaml` toplevel do:

```text
OCaml version 4.14.0
Enter #help;; for help.

# #use_output "dune ocaml top src";;
```

### Running dockcross Linux from any x86/x86_64-capable OS

**Running from Windows?**

* You will need a POSIX shell. If you have DkML on your machine,
  `with-dkml bash` will start a POSIX shell. Other alternatives are a standalone
  MSYS2 or Cygwin installation.

**Docker container running slow?**

* You may need more memory available in your Docker container.
* Docker Desktop on Windows, when its `Settings > General` has enabled `Use the WSL 2 based engine`,
  will have slow file operations. The
  [recommendation for performance](https://learn.microsoft.com/en-us/windows/wsl/filesystems)
  is to use the WSL filesystem, but since `dockcross` mounts Windows directories into Docker you don't have that
  option.

#### Linux x86 within container

In a POSIX compatible shell (ex. `bash` on Linux and macOS) do the following:

```shell
sh ci/setup-dkml/pc/setup-dkml-linux_x86.sh --SKIP_OPAM_MODIFICATIONS=true

sh ci/git-clone.sh -l
.ci/sd4/opamrun/cmdrun sh ci/download-build-tools.sh linux_x86 manylinux2014-linux_x86 .ci/dockcross
.ci/sd4/opamrun/cmdrun sh ci/git-clone.sh -p .ci/dockcross/bin/cmake
.ci/sd4/opamrun/cmdrun -it bash
```

You will now be inside the Linux dockcross container with all of the SquirrelScout
source code available in the `/work` directory. Run the following to build the source
code into the `build/` build directory:

```shell
export PATH="$PWD/.ci/dockcross/bin:$PATH"
export OPAMROOTISOK=1

cmake --version
> cmake version 3.25.2
>
> CMake suite maintained and supported by Kitware (kitware.com/cmake).

# Note: On some platforms `sudo` is not required for the following commands.

sudo sh ci/exec.sh linux_x86 cmake --preset=dbg-linux_x86
sudo sh ci/exec.sh linux_x86 cmake --build --preset=dbg-main
sudo sh ci/exec.sh linux_x86 ctest --preset=dbg-test
```

#### Linux x86_64 within container

In a POSIX compatible shell (ex. `bash` on Linux and macOS) do the following:

```shell
sh ci/setup-dkml/pc/setup-dkml-linux_x86_64.sh --SKIP_OPAM_MODIFICATIONS=true --dockcross_image=dockcross/manylinux_2_28-x64

sh ci/git-clone.sh -l
.ci/sd4/opamrun/cmdrun sh ci/download-build-tools.sh linux_x86_64 manylinux_2_28-linux_x86_64 .ci/dockcross
.ci/sd4/opamrun/cmdrun sh ci/git-clone.sh -p .ci/dockcross/bin/cmake
.ci/sd4/opamrun/cmdrun -it bash
```

You will now be inside the Linux dockcross container with all of the SquirrelScout
source code available in the `/work` directory. Run the following to build the source
code into the `build/` build directory:

```shell
export PATH="$PWD/.ci/dockcross/bin:$PATH"
export OPAMROOTISOK=1

cmake --version
> cmake version 3.25.2
>
> CMake suite maintained and supported by Kitware (kitware.com/cmake).

# Note: On some platforms `sudo` is not required for the following commands.

sudo sh ci/exec.sh linux_x86_64 cmake --preset=dbg-linux_x86_64
sudo sh ci/exec.sh linux_x86_64 cmake --build --preset=dbg-main
sudo sh ci/exec.sh linux_x86_64 ctest --preset=dbg-test
```

#### Direct Android NDK x86_64 within container

In a POSIX compatible shell (ex. `bash` on Linux and macOS) do the following:

```shell
sh ci/setup-dkml/pc/setup-dkml-linux_x86_64.sh --SKIP_OPAM_MODIFICATIONS=true --dockcross_image=dockcross/manylinux_2_28-x64

sh ci/git-clone.sh -l
.ci/sd4/opamrun/cmdrun sh ci/download-build-tools.sh linux_x86_64 manylinux_2_28-android_x86_64 .ci/local
.ci/sd4/opamrun/cmdrun sh ci/git-clone.sh -p .ci/local/bin/cmake
.ci/sd4/opamrun/cmdrun -it bash
```

You will now be inside the Linux dockcross container with all of the SquirrelScout
source code available in the `/work` directory. Run the following to build the source
code into the `build/` build directory:

```shell
export PATH="$PWD/.ci/dockcross/bin:$PATH"
export OPAMROOTISOK=1

cmake --version
> cmake version 3.25.2
>
> CMake suite maintained and supported by Kitware (kitware.com/cmake).

# Note: On some platforms `sudo` is not required for the following commands.

sudo sh ci/exec.sh linux_x86_64 cmake --preset=ci-linux_x86_64_X_android_x86_64
sudo sh ci/exec.sh linux_x86_64 cmake --build --preset=ci-main
sudo sh ci/exec.sh linux_x86_64 ctest --preset=ci-test
```

## Design

### Lang = OCamlDune

All compilation (bytecode or native) and host/cross-compiling
is handled by Dune.

The `CMAKE_OCamlDune_COMPILER` is the host ABI `ocamlopt.opt` (or
`ocamlopt`). That is sufficient for Dune to locate `ocamlfind`
and `ocamlc.opt` which are in the same directory.

#### OCaml sub-build

Unless `-D CMAKE_OCamlDune_COMPILER_EXTERNAL_REQUIRED=ON` (or any
truthy value), DKSDK will automatically build OCaml, findlib
and Dune in what we call the **OCaml sub-build**.

##### Changing C and assembly flags

Debugging, optimization and other flags that are set for the assembler
or C compiler strongly influence how OCaml code compiles. That is
because OCaml delegates to the assembler and C compiler for native
code generation.

In CMake those flags are controlled by [CMAKE_\<LANG>_FLAGS](https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_FLAGS.html)
and its variants `CMAKE_<LANG>_FLAGS_<CONFIG>`. For example,
`CMAKE_C_FLAGS_DEBUG` are the flags given to the C compiler during a
Debug build.

When you change those flags in the CMake cache, the OCaml sub-build
is not automatically rebuilt. You will need to remove the `_ocaml`
directory completely in your build directory, and then re-run the
CMake generator.

##### Custom OCaml source code

The source code for the OCaml sub-build uses:

* <https://github.com/ocaml/ocaml.git>
* <https://github.com/alainfrisch/flexdll.git> (only for Windows)
* <https://github.com/diskuv/dkml-compiler.git>
* <https://github.com/diskuv/dkml-runtime-common.git>

See [All IDEs: CMakeUserPresets.json](#all-ides-cmakeuserpresetsjson)
for the `FETCHCONTENT_SOURCE_DIR_*` variables you would use to point
to your own custom OCaml code.

When you first run the CMake generator (`cmake -G ...`, or
"Reload CMake Project" in the CLion IDE),
CMake will use the `FETCHCONTENT_SOURCE_DIR_*` variables you have
set.

After the first run of the CMake generator any **changes**
to the source code in your `ocaml`, `flexdll`, `dkml-compiler` and
`dkml-runtime-common` **will be ignored**. To get CMake to see your
changes you will have to:

1. Remove the `DkSDKFiles/o/160-dune/exports_COMMON.cmake` file
   from your binary (aka. build) directory.
2. Re-run the CMake generator.

### Lang = OCamlHostBytecode, OCamlTargetBytecode, OCamlHostNative, OCamlTargetNative

This has yet to be implemented.
Most of the `Lang=OCamlDune` modules can be re-used as-is.
Generally only the `CMakeOCamlHostBytecodeInformation.cmake`
(etc.) module will need to be written; that will give CMake the
compiler and linking command lines to build libraries and executables.

## Setup

### direnv

> This is optional but highly recommended on Unix, especially if you use
> Visual Studio Code

[direnv]: https://direnv.net/

On Unix systems [direnv](https://direnv.net/) will let you configure your environment
when your interactive shell enters your project directory.

The setup below will configure:

* `dune` to be in your PATH
* `cmake` to be in your PATH
* `opam` to be in your PATH

First, install [direnv].

Second, you will need to run CMake once (just the `-G` configure phase).

Third, in your project source directory, create the file `.envrc`:

```sh
#!/bin/sh
# If you need to modify the rules, do not edit this file,
# but place your changes in `user.envrc` in this directory.
for _dksdk_build_dir in build_dev build; do
    if [ -e "$_dksdk_build_dir/DkSDKFiles/ocaml_project.source.sh" ]; then
        # shellcheck disable=SC1090
        dotenv "$_dksdk_build_dir/DkSDKFiles/ocaml_project.source.sh"
        break
    fi
done
unset _dksdk_build_dir
if [ -n "${CMAKE_COMMAND_DIR:-}" ] && [ -x "$CMAKE_COMMAND_DIR/cmake" ]; then
    PATH_add "$CMAKE_COMMAND_DIR"
fi
if [ -n "${CMAKE_DUNE_DIR:-}" ] && [ -x "$CMAKE_DUNE_DIR/dune" ]; then
    PATH_add "$CMAKE_DUNE_DIR"
fi
if [ -n "${CMAKE_OCAMLDUNE_OPAM_HOME:-}" ] && [ -x "$CMAKE_OCAMLDUNE_OPAM_HOME/bin/opam" ]; then
    PATH_add "$CMAKE_OCAMLDUNE_OPAM_HOME/bin"
fi

# Lets you add your own modifications
source_env_if_exists user.envrc

# Advanced: If you uncomment, your IDEs won't work, but you can inspect your project with `opam list`.
# if [ -n "${CMAKE_OCAMLDUNE_OPAM_ROOT:-}" ] && [ -e "$CMAKE_OCAMLDUNE_OPAM_ROOT/config" ]; then
#     export OPAMROOT="$CMAKE_OCAMLDUNE_OPAM_ROOT"
# fi
# if [ -e "_dn/_opam/.opam-switch/switch-config" ]; then
#     export OPAMSWITCH="$(expand_path _dn)"
# fi
```

Finally, run:

```sh
cd YOUR_PROJECT_DIRECTORY
direnv allow
```

### All IDEs: CMakeUserPresets.json

We suggest you make your own `CMakeUserPresets.json` file. A good starting
point is [CMakeUserPresets-SUGGESTED.json](./[CMakeUserPresets-SUGGESTED.json]),
which you can copy into your own `CMakeUserPresets.json`.

Customize it according to the rules:

1. Any developer overrides of source code go into the `dev-source-dirs`
hidden preset. In the template above, you have checked out the
source code for `dksdk-cmake` in the sibling directory `../dksdk-cmake`
so the standard Git checkout of `dksdk-cmake` will not happen. Add
or remove as many source code overrides as you need.
2. Each source code override directory is copied in its entirety. Often
CMake can't copy a local `_opam` directory but will silently continue.
3. The same CMakeUserPresets.json can be used for all your OCaml packages,
as long as you check out all of your OCaml packages in the same source
tree as siblings of each other.

#### `FETCHCONTENT_SOURCE_DIR_*`

The source code for the OCaml sub-build uses:

* <https://github.com/ocaml/ocaml.git>
* <https://github.com/alainfrisch/flexdll.git>
* <https://github.com/diskuv/dkml-compiler.git>
* <https://github.com/diskuv/dkml-runtime-common.git>

The source code needed by the `DkSDK_OpamPackages` target
needs `dkml-compiler` and `dkml-runtime-common` above, and also:

* <https://github.com/diskuv/dkml-runtime-distribution.git>

You can use your own source code and edits by checking out
any or all of the git repositories above, and setting
the corresponding CMake variables:

* `FETCHCONTENT_SOURCE_DIR_OCAML`
* `FETCHCONTENT_SOURCE_DIR_FLEXDLL`
* `FETCHCONTENT_SOURCE_DIR_DKML-COMPILER`
* `FETCHCONTENT_SOURCE_DIR_DKML-RUNTIME-COMMON`
* `FETCHCONTENT_SOURCE_DIR_DKML-RUNTIME-DISTRIBUTION`

For example, if you have checked out `dkml-compiler` and
`dkml-runtime-common` and `dkml-runtime-distribution`
as sibling directories to your project code,
then you can use the following in your project's `CMakeUserPresets.json`:

```json5
{
  // The full documentation is at https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html.
  // You CANNOT include comments like this one in your .json files though!

  version: 3,
  // ... any other fields ...

  "configurePresets": [
    {
      "name": "some_name",
      // ... any other fields ...

      "cacheVariables": [
        {
          "FETCHCONTENT_SOURCE_DIR_DKML-RUNTIME-COMMON": {
            "type": "FILEPATH",
            "value": "${sourceParentDir}/dkml-runtime-common"
          },
          "FETCHCONTENT_SOURCE_DIR_DKML-RUNTIME-DISTRIBUTION": {
            "type": "FILEPATH",
            "value": "${sourceParentDir}/dkml-runtime-distribution"
          },
          "FETCHCONTENT_SOURCE_DIR_DKML-COMPILER": {
            "type": "FILEPATH",
            "value": "${sourceParentDir}/dkml-compiler"
          }
        }
      ]
    }
  ]
}
```

When you first run the CMake generator (`cmake -G ...`, or
"Reload CMake Project" in the CLion IDE),
CMake will use those `FETCHCONTENT_SOURCE_DIR_*` variables you have
set.

Changes to those directories should automatically reconfigure CMake
and rebuild affected CMake targets. If not, you can manually
configure CMake again.

The exception is [OCaml sub-build](#ocaml-sub-build); see the link
for how it behaves differently.

### Visual Studio Code

Use the `OCaml Platform` plugin to edit your OCaml source code:

* Press Cmd-Shift-P on macOS, or Windows-Shift-P on Windows, to open the
  Visual Studio commands dialog
* Choose `OCaml: Select a Sandbox for this Workspace`
  * Choose ``dkml`` (Windows) or ``dksdk-util`` (macOS/Linux)

If you use a CMake cross-compiling compiler, then CMake will not
build the host ABI files that are expected in `_build/default`.
You will instead need to run: `dune build` from the command line
to get `OCaml Platform` working.

#### Windows

On Windows you will need to install DkML. Nothing else is needed.

#### macOS or Linux

Do the following:

```bash
opam switch create dksdk-util 4.14.0
opam install --switch dksdk-util ocaml-lsp-server ocamlformat.0.24.1

sudo install "$(opam var --switch dksdk-util bin)/ocamllsp" /usr/local/bin/
sudo install "$(opam var --switch dksdk-util bin)/ocamlformat" /usr/local/bin/
sudo install "$(opam var --switch dksdk-util bin)/ocamlformat-rpc" /usr/local/bin/
```

### CLion

Use the [ReasonML plugin](https://giraud.github.io/reasonml-idea-plugin/)
because it is the best supported OCaml (and Reason and ReScript) in IntelliJ.
But it doesn't use Dune RPC or even the OCaml Language Server, so it won't
work with modern OCaml.

You'll find it best to use [Visual Studio Code](#visual-studio-code).
