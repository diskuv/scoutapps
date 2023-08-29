# Squirrel Scout - OCaml Backend

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
./dk dksdk.vscode.ocaml.configure
```

On Debian or Ubuntu, also do:

```sh
sudo apt install libsqlite3-dev
```

### Echo Server

1. **Unix** (including Linux and macOS): Run `sh ci/git-clone.sh -l`

   **Windows**: Make sure you have installed [DkML](https://diskuv.com/dkmlbook/)
   first, and then run `with-dkml sh ci/git-clone.sh -l`
2. Open this project in CLion or any other IDE which can read CMake projects.
   > If you are on Windows and use Visual Studio Code as your IDE, then launch Visual
   > Studio Code by running `with-dkml env -u HOME code` from the Run Prompt (⊞ Win + R).

   Then select the `darwin_arm64 (debug)`, `darwin_x86_64 (debug)`,
   `linux_x86_64 (debug)`, or `windows_x86_64 (debug)` CMake configuration preset.
3. Press **Build**. Be prepared the first time may take up to 15 minutes.

   *You may have to press Build a few times because of Errata 1.0.0.E1.*
4. Run the `main-cli` executable. Most IDEs you can select from a drop-down (like CLion)
   or navigate to `src/MainCLI/main-cli` and press Execute or Run (like Visual Studio
   Code). If you can't find the executable, run `build_dev/src/MainCLI/main-cli` from
   the command line.
   
   You should first use the `--help` option to see all the options. Then use the
   `-v` option.
   
   *Keep this terminal open!*

You now have a running echo server!

### macOS/Linux Echo Client

On macOS and Linux, the best tool for seeing the echoes is netcat. On macOS the `nc`
executable is built-in; on Linux you may need to do a `apt install netcat` or
`yum install netcat`. Once you have netcat you should do:

```console
$ nc localhost 8010
hello
hello # <--- the echo
```

Press Ctrl-D to finish.

### Windows Echo Client

You can download Netcat (actually `ncat`) inside the
[https://nmap.org/dist/ncat-portable-5.59BETA1.zip zip file](https://nmap.org/dist/ncat-portable-5.59BETA1.zip).
To ensure the file hasn't been tampered with, you can check the
[cryptographic signatures](https://nmap.org/book/install.html#inst-integrity)
if you have GPG.

Once you have `ncat.exe`, run:

```winbatch
.\ncat.exe localhost 8010
hello
hello # <--- the echo
```

Press Ctrl-Z on an empty line to finish.
