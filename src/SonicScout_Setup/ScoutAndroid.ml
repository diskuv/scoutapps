let build_reldir = Fpath.v "build_dev"
let user_presets_relfile = Fpath.v "CMakeUserPresets.json"

let clean areas =
  let open Utils in
  let open Bos in
  let cwd = OS.Dir.current () |> rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutAndroid") in
  if List.mem `DkSdkSourceCode areas then begin
    start_step "Cleaning SonicScoutAndroid DkSDK source code";
    DkFs_C99.Path.rm ~recurse:() ~force:() ~kill:()
      Fpath.
        [
          projectdir / "fetch" / "dkml-compiler";
          projectdir / "fetch" / "dkml-runtime-common";
          projectdir / "fetch" / "dkml-runtime-distribution";
          projectdir / "fetch" / "dksdk-access";
          projectdir / "fetch" / "dksdk-cmake";
          projectdir / "fetch" / "dksdk-ffi-c";
          projectdir / "fetch" / "dksdk-ffi-java";
          projectdir / "fetch" / "dksdk-ffi-ocaml";
          projectdir / "fetch" / "dksdk-opam-repository-core";
          projectdir / "fetch" / "dksdk-opam-repository-js";
          projectdir / "fetch" / "ocaml-backend";
        ]
    |> rmsg
  end;
  if List.mem `DkSdkCMake areas then begin
    start_step "Cleaning SonicScoutAndroid dksdk-cmake source code";
    DkFs_C99.Path.rm ~recurse:() ~force:() ~kill:()
      Fpath.[ projectdir / "fetch" / "dksdk-cmake" ]
    |> rmsg
  end;
  if List.mem `Builds areas then begin
    start_step "Cleaning SonicScoutAndroid build artifacts";
    DkFs_C99.Path.rm ~recurse:() ~force:() ~kill:()
      Fpath.
        [
          projectdir / "dkconfig" / "build";
          projectdir / "data" / ".cxx";
          projectdir / "data" / "build";
          projectdir / "app" / "build";
          projectdir // user_presets_relfile;
        ]
    |> rmsg;
    let ffijava = Fpath.(projectdir / "fetch" / "dksdk-ffi-java") in
    DkFs_C99.Path.rm ~recurse:() ~force:() ~kill:()
      Fpath.
        [
          ffijava / "buildSrc" / "build";
          ffijava / "core" / "abi" / "build";
          ffijava / "core" / "gradle" / "build";
          ffijava / "ffi-java" / "build";
          ffijava / "ffi-java-android" / "build";
          ffijava / "ffi-java-android-standalone" / "build";
          ffijava / "ffi-java-jdk8" / "build";
          ffijava / "ffi-java-jdk11" / "build";
        ]
    |> Utils.rmsg
  end

let run ?opts ~slots () =
  let open Bos in
  Utils.start_step "Building SonicScoutAndroid";
  let cwd = OS.Dir.current () |> Utils.rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutAndroid") in
  let dk_env = Utils.dk_env ?opts () in
  let dk = Utils.dk ~env:dk_env ~slots in
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
      if Sys.win32 then
        Logs.info (fun l ->
            l "NOTE: Extracting Gradle can take several minutes");
      dk [ "dksdk.gradle.download"; "ALL"; "NO_SYSTEM_PATH" ];
      dk [ "dksdk.android.ndk.download"; "NO_SYSTEM_PATH" ];
      (* was: dk [ "dksdk.android.gradle.configure"; "OVERWRITE" ]; *)
      (* Display the Java toolchains. https://docs.gradle.org/current/userguide/toolchains.html *)
      RunGradle.run ~env:dk_env ~debug_env:() ~no_local_properties:()
        ~projectdir
        [ "-p"; "fetch/dksdk-ffi-java/core"; "-q"; "javaToolchains" ];
      RunGradle.run ~env:dk_env ~debug_env:() ~no_local_properties:()
        ~projectdir
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
        ])
    ()
  |> Utils.rmsg;
  slots
