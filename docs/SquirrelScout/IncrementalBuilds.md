# Incremental Builds

## SonicScoutBackend syncing with SonicScoutAndroid

### Destination: us/SonicScoutAndroid/fetch/ocaml-backend/

With [us/SonicScoutAndroid/dkproject.jsonc](../../us/SonicScoutAndroid/dkproject.jsonc)
configuration the following command performed by
[src/SonicScout_Setup/ScoutAndroid.ml](../../src/SonicScout_Setup/ScoutAndroid.ml)

```sh
us/SonicScoutAndroid/dk dksdk.project.get
```

clones [us/SonicScoutBackend/](../../us/SonicScoutBackend/) to [us/SonicScoutAndroid/fetch/ocaml-backend/](../../us/SonicScoutAndroid/fetch/ocaml-backend/).

The cloning is performed by
[dksdk-access/cmake/run/CloneSource.cmake](https://gitlab.com/diskuv/dksdk-access/-/blob/20b8fa9704b87b0c550ccfd1c269aa4d03080983/cmake/run/CloneSource.cmake)
and will not copy the `tests/` folder and any build directories.

In particular, the cloning is (replace directories):

```sh
cmake -D INTERACTIVE=1 -D CONFIG_FILE=Y:/source/scoutapps/us/SonicScoutAndroid/dkproject.jsonc  -D COMMAND_GET=Y:/source/scoutapps/us/SonicScoutAndroid/fetch -D CACHE_DIR=C:/Users/beckf/AppData/Local/Programs/DkCoder/work/dksdk___project___get -P C:/Users/beckf/AppData/Local/Programs/DkCoder/work/dksdk___project___get/dksdk-access-src/cmake/run/get.cmake
```

which invokes:

```sh
cmake -D CMAKE_INSTALL_PREFIX=Y:/source/scoutapps/us/SonicScoutAndroid/fetch/ocaml-backend -P C:/Users/beckf/AppData/Local/Programs/DkCoder/work/dksdk___project___get/dksdk-access-src/cmake/run/CloneSource.cmake
```

#### IMMUTABLE Variation: us/SonicScoutAndroid/fetch/ocaml-backend-6ed153/

With [us/SonicScoutAndroid/dkproject.jsonc](../../us/SonicScoutAndroid/dkproject.jsonc)
configuration:

```json
urls:[
  "file://${projectDir}/fetch/${dependencyName}?mirror=${sourceParentDir}/SonicScoutBackend&immutable"
]
```

the IMMUTABLE flag is used. That will first calculate the MD5 checksum of the source files,
and add 6 characters of the MD5 checksum to the destination directory (`ocaml-backend-6ed153`).

By doing this, it is trivial for CMake to detect changes when `ocaml-backend-6ed153` is
used as a source directory in subsequent steps.

### Destination: /home/dksdkbob/source/ded2cc2f/fetch/ocaml-backend

> - Log into the DkSDK WSL2 container with `wsl -d DkSDK-1.0-Debian-12-NDK-23.1.7779620 -e /usr/bin/bash`
>
> - The `ded2cc2f` will change.

The destination can be rebuilt by rerunning the CMake configure:

```sh
rm -rf /home/dksdkbob/source/ded2cc2f/build/_deps/ocaml-backend-*
OPAMNODEPEXTS=1 /usr/bin/ninja -C /home/dksdkbob/source/ded2cc2f/build rebuild_cache
```

When the Gradle target `:data:configureCMakeDebug[arm64-v8a]` is called,
the [us/SonicScoutAndroid/CMakeLists.txt](../../us/SonicScoutAndroid/CMakeLists.txt)
is configured **inside the DkSDK WSL2 container**.

You can rerun the CMake configure:

```sh
rm -rf /home/dksdkbob/source/ded2cc2f/build/_deps/ocaml-backend-*
DKCODER_TTL_MINUTES=0 OPAMNODEPEXTS=1 /usr/bin/ninja -C /home/dksdkbob/source/ded2cc2f/build rebuild_cache
```

The CMake configure will include the
[us/SonicScoutAndroid/dependencies/CMakeLists.txt](../../us/SonicScoutAndroid/dependencies/CMakeLists.txt)
script, which has:

```cmake
DkSDKFetchContent_DeclareSecondParty(
        NAME ocaml-backend
        GIT_REPOSITORY "https://github.com/SquirrelScout/ocaml-backend.git"
        GIT_TAG teamNamesTable)
```

`DkSDKFetchContent_DeclareSecondParty` will use the
[us/SonicScoutAndroid/dkproject.jsonc](../../us/SonicScoutAndroid/dkproject.jsonc)
to:

1. Do immediate mirroring from native Windows `us/SonicScoutBackend` to WSL2's `/home/dksdkbob/source/ded2cc2f/fetch/ocaml-backend`
   by `DkSDKQuerySource_Init()` and `DkSDKQuerySource_FindSource()` of
   [dksdk-access/cmake/DkSDKQuerySource.cmake](https://gitlab.com/diskuv/dksdk-access/-/blob/20b8fa9704b87b0c550ccfd1c269aa4d03080983/cmake/DkSDKQuerySource.cmake).
   Ultimately the following is performed:

   ```cmake
   DkSDKCloneSource_CloneLocalDir(
        SOURCE_DIR /mnt/y/source/scoutapps/us/SonicScoutBackend
        DESTINATION_DIR /home/dksdkbob/source/ded2cc2f/fetch/ocaml-backend)
   ```

2. `FetchContent_Declare(ocaml-backend URL /home/dksdkbob/source/ded2cc2f/fetch/ocaml-backend)`

You can rerun the mirroring manually with:

```sh
cmake -D INTERACTIVE=1 -D CONFIG_FILE=/home/dksdkbob/source/ded2cc2f/dkproject.jsonc -D COMMAND_GET=/home/dksdkbob/source/ded2cc2f/fetch -D SOURCE_DIR=/mnt/y/source/scoutapps/us/SonicScoutAndroid -D CACHE_DIR=/tmp/dksdk___project___get -P /mnt/y/source/scoutapps/us/SonicScoutAndroid/fetch/dksdk-access/cmake/run/get.cmake
```

### Destination: /home/dksdkbob/source/ded2cc2f/build/_deps/ocaml-backend-src

> - Log into the DkSDK WSL2 container with `wsl -d DkSDK-1.0-Debian-12-NDK-23.1.7779620 -e /usr/bin/bash`
>
> - The `ded2cc2f` will change.

Because the last destination's `DkSDKFetchContent_DeclareSecondParty()` did:

```cmake
FetchContent_Declare(ocaml-backend URL /home/dksdkbob/source/ded2cc2f/fetch/ocaml-backend)
```

the CMake configure that includes
[us/SonicScoutAndroid/dependencies/CMakeLists.txt](../../us/SonicScoutAndroid/dependencies/CMakeLists.txt)
script does:

```cmake
DkSDKFetchContent_MakeAvailableToDune(ocaml-backend)
```

`DkSDKFetchContent_MakeAvailableToDune` and `DkSDKFetchContent_MakeAvailable` are wrappers
around `FetchContent_MakeAvailable` which is an internal CMake command that populates
the `_deps/` build folder.

**However**, `FetchContent_MakeAvailable` has no way to tell if a local directory URL
`FetchContent_Declare(ocaml-backend URL /home/dksdkbob/source/ded2cc2f/fetch/ocaml-backend)`
has an update. It simply copies the local directory URL to
`/home/dksdkbob/source/ded2cc2f/build/_deps/ocaml-backend-src`
**if and only if it is missing**.

This poor change detection is avoided with the [IMMUTABLE variation](#immutable-variation-ussonicscoutandroidfetchocaml-backend-6ed153).
