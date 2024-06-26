open Utils

let run ~next () =
  let open Bos in
  start_step "Building SonicScoutAndroid with Gradle";
  let cwd = OS.Dir.current () |> rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutAndroid") in
  let env = OS.Env.current () |> rmsg in
  let dk_env =
    if next then
      OSEnvMap.(
        add "DKSDK_FFI_JAVA_REPO_1_0"
          "https://gitlab.com/diskuv/distributions/1.0/dksdk-ffi-java.git#next"
          env
        |> add "DKSDK_CMAKE_REPO_1_0"
             "https://gitlab.com/diskuv/distributions/1.0/dksdk-cmake.git#next")
    else env
  in
  let dk = dk ~env:dk_env in
  let git args =
    Logs.info (fun l -> l "git %a" (Fmt.list ~sep:Fmt.sp Fmt.string) args);
    OS.Cmd.run Cmd.(v "git" %% of_list args) |> rmsg
  in
  let dkmlHostAbi =
    match Tr1HostMachine.abi with
    | `darwin_x86_64 -> "darwin_x86_64"
    | `darwin_arm64 -> "darwin_arm64"
    | `windows_x86_64 -> "windows_x86_64"
    | `windows_x86 -> "windows_x86"
    | `linux_x86_64 -> "linux_x86_64"
    | `linux_x86 -> "linux_x86"
    | _ ->
        failwith "Currently your host machine is not supported by Sonic Scout"
  in
  OS.Dir.with_current projectdir
    (fun () ->
      let cmake = Fpath.(projectdir / ".ci" / "cmake" / "bin" / "cmake") in
      dk [ "dksdk.project.get" ];
      dk [ "dksdk.cmake.link"; "QUIET" ];
      (* You can ignore the error if you got 'failed to create symbolic link' for dksdk.ninja.link *)
      dk [ "dksdk.ninja.link"; "QUIET" ];
      dk [ "dksdk.java.jdk.download"; "NO_SYSTEM_PATH"; "JDK"; "8" ];
      dk [ "dksdk.java.jdk.download"; "NO_SYSTEM_PATH"; "JDK"; "17" ];
      dk [ "dksdk.gradle.download"; "ALL"; "NO_SYSTEM_PATH" ];
      dk [ "dksdk.android.ndk.download"; "NO_SYSTEM_PATH" ];
      dk [ "dksdk.android.gradle.configure"; "OVERWRITE" ];
      git [ "-C"; "fetch/dksdk-ffi-java"; "clean"; "-d"; "-x"; "-f" ];
      (* Display the Java toolchains. https://docs.gradle.org/current/userguide/toolchains.html *)
      dk
        [
          "dksdk.gradle.run";
          "ARGS";
          "-p";
          "fetch/dksdk-ffi-java/core";
          "-q";
          "javaToolchains";
        ];
      dk
        [
          "dksdk.gradle.run";
          "ARGS";
          "-p";
          "fetch/dksdk-ffi-java/core";
          ":abi:publishToMavenLocal";
          ":gradle:publishToMavenLocal";
        ];
      dk
        [
          "dksdk.gradle.run";
          "ARGS";
          "-p";
          "fetch/dksdk-ffi-java";
          ":ffi-java:publishToMavenLocal";
          "-P";
          Fmt.str "cmakeCommand=%a" Fpath.pp cmake;
          "-P";
          "disableAndroidNdk=1";
          "-P";
          Fmt.str "dkmlHostAbi=%s" dkmlHostAbi;
        ];
      dk
        [
          "dksdk.gradle.run";
          "ARGS";
          "-p";
          "fetch/dksdk-ffi-java";
          ":ffi-java-android:publishToMavenLocal";
          "-P";
          Fmt.str "cmakeCommand=%a" Fpath.pp cmake;
          "-P";
          "disableAndroidNdk=1";
          "-P";
          Fmt.str "dkmlHostAbi=%s" dkmlHostAbi;
        ])
    ()
  |> rmsg
