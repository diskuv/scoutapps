open Utils

let run ~next () =
  let open Bos in
  start_step "Building SonicScoutBackend";
  let cwd = OS.Dir.current () |> rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in
  let dk_env = dk_env ~next in
  let dk = dk ~env:dk_env in
  let preset =
    match Tr1HostMachine.abi with
    | `darwin_x86_64 -> "dev-AppleIntel"
    | `darwin_arm64 -> "dev-AppleSilicon"
    | `windows_x86_64 -> "dev-Windows64"
    | `linux_x86_64 -> "dev-Linux-x86_64"
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
      let user_presets = Fpath.v "CMakeUserPresets.json" in
      if not (OS.File.exists user_presets |> rmsg) then
        OS.File.write user_presets
          (OS.File.read (Fpath.v "CMakeUserPresets-SUGGESTED.json") |> rmsg)
        |> rmsg;

      OS.Cmd.run Cmd.(v (p cmake) % "--preset" % preset) |> rmsg;

      if preset <> "" then assert false
      (*
         dk [ "dksdk.java.jdk.download"; "NO_SYSTEM_PATH"; "JDK"; "8" ];
         dk [ "dksdk.java.jdk.download"; "NO_SYSTEM_PATH"; "JDK"; "17" ];
         if Sys.win32 then
           Logs.info (fun l ->
               l "NOTE: Extracting Gradle can take several minutes");
         dk [ "dksdk.gradle.download"; "ALL"; "NO_SYSTEM_PATH" ];
         dk [ "dksdk.android.ndk.download"; "NO_SYSTEM_PATH" ];
         (* dk [ "dksdk.android.gradle.configure"; "OVERWRITE" ]; *)
         git [ "-C"; "fetch/dksdk-ffi-java"; "clean"; "-d"; "-x"; "-f" ];
         (* Display the Java toolchains. https://docs.gradle.org/current/userguide/toolchains.html *)
         RunGradle.run ~env:dk_env ~debug_env:() ~projectdir
           [ "-p"; "fetch/dksdk-ffi-java/core"; "-q"; "javaToolchains" ];
         RunGradle.run ~env:dk_env ~debug_env:() ~projectdir
           [
             "-p";
             "fetch/dksdk-ffi-java/core";
             ":abi:publishToMavenLocal";
             ":gradle:publishToMavenLocal";
           ];
         RunGradle.run ~env:dk_env ~debug_env:() ~projectdir
           [
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
         RunGradle.run ~env:dk_env ~debug_env:() ~projectdir
           [
             "-p";
             "fetch/dksdk-ffi-java";
             ":ffi-java-android:publishToMavenLocal";
             "-P";
             Fmt.str "cmakeCommand=%a" Fpath.pp cmake;
             "-P";
             "disableAndroidNdk=1";
             "-P";
             Fmt.str "dkmlHostAbi=%s" dkmlHostAbi;
           ] *))
    ()
  |> rmsg
