# DkCoder migration

Currently DkCoder is used for the IDE experience. It produces bytecode and a Merlin file.

Android Gradle Plugin will use DkSDK CMake, however, meaning that what is in the IDE is not exactly what is run in Android.

There are two relevant Diskuv goals:

1. DkSDK CMake uses DkCoder underneath (`dksdk-coder`) to produce native code.
2. DkCoder produces native shared libraries by linking an embedded bytecode interpreter into a skeleton shared library. That is, expand `Run` and `Repl` to `SharedLib`.

Either of these two goals will remove the DkSDK CMake / DkCoder discrepancy. The latter will make for a fast development experience (no WSL2).
