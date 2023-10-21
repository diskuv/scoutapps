# SquirrelScout_Scouter

## Command Line

### Initial Setup

> If you use Windows Subsystem for Linux (WSL2), follow [WSL2.md](./WSL2.md)
> before doing any of the following instructions.

FIRST you will need external source code. On Unix run:

```shell
sh ci/git-clone.sh -l
sh ci/git-clone.sh -p .ci/cmake/bin/cmake
```

or on Windows with DkML installed run:

```powershell
with-dkml sh ci/git-clone.sh -l
with-dkml sh ci/git-clone.sh -p .ci/cmake/bin/cmake
```

SECOND, run the following commands in Unix or Windows PowerShell:

```sh
./dk dksdk.cmake.link
./dk dksdk.ninja.link
./dk dksdk.java.jdk.download NO_SYSTEM_PATH
./dk dksdk.gradle.download ALL NO_SYSTEM_PATH
./dk dksdk.android.ndk.download NO_SYSTEM_PATH
./dk dksdk.android.gradle.configure OVERWRITE

git -C fetch/dksdk-ffi-java clean -d -x -f
./dk dksdk.gradle.run ARGS -p fetch/dksdk-ffi-java/core :abi:publishToMavenLocal :gradle:publishToMavenLocal
./dk dksdk.gradle.run ARGS -p fetch/dksdk-ffi-java :ffi-java:publishToMavenLocal -P "cmakeCommand=$PWD/.ci/cmake/bin/cmake" -P disableAndroidNdk=1
./dk dksdk.gradle.run ARGS -p fetch/dksdk-ffi-java :ffi-java-android:publishToMavenLocal -P "cmakeCommand=$PWD/.ci/cmake/bin/cmake" -P disableAndroidNdk=1
git -C fetch/dksdk-ffi-java clean -d -x -f
```

You can verify parts of the setup are working by running:

```sh
./dk dksdk.gradle.run ARGS -q javaToolchains
```

where you will see something like:

```text
 + Options
     | Auto-detection:     Enabled
     | Auto-download:      Enabled

+ Eclipse Temurin JDK 17.0.6+10
     | Location:           /home/YOURNAME/source/SquirrelScout_Scouter/.ci/local/share/jdk
     | Language Version:   17
     | Vendor:             Eclipse Temurin
     | Architecture:       amd64
     | Is JDK:             true
     | Detected by:        Gradle property 'org.gradle.java.installations.paths'
```

Finally, if you want to run Android Studio, run:

```shell
# One-time
./dk dksdk.android.studio.download NO_SYSTEM_PATH

# Each time
GDK_SCALE=2 ./dk dksdk.android.studio.run
```

### Testing

```sh
./dk dksdk.gradle.run ARGS check
```

You should see a lot of output, but the end should look like:

```text
BUILD SUCCESSFUL in 1m 28s
43 actionable tasks: 43 executed
```

### Building

```sh
git clone git@gitlab.com:diskuv/distributions/1.0/dksdk-ffi-java.git
cd dksdk-ffi-java
./dk dksdk.gradle.run ARGS :core:abi:publishToMavenLocal :core:gradle:publishToMavenLocal
```

## Licenses

- The Cartman image is from https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/
