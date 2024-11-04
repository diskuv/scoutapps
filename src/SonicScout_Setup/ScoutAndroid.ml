let build_reldir = Fpath.v "build_dev"
let user_presets_relfile = Fpath.v "CMakeUserPresets.json"

let clean areas =
  let open Utils in
  let open Bos in
  let cwd = OS.Dir.current () |> rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutAndroid") in
  let fetch = Fpath.(projectdir / "fetch") in
  if List.mem `DkSdkSourceCode areas then begin
    start_step "Cleaning SonicScoutAndroid DkSDK source code";
    let more_paths =
      let exists = OS.Dir.exists fetch |> rmsg in
      if exists then
        (* Get rid of `fetch / ocaml-backend-6ed153`, etc. *)
        let subdirs = OS.Dir.contents ~rel:true fetch |> rmsg in
        List.map
          (fun p ->
            if String.starts_with ~prefix:"ocaml-backend-" (Fpath.basename p)
            then Fpath.[ fetch // p ]
            else [])
          subdirs
        |> List.flatten
      else []
    in
    DkFs_C99.Path.rm ~recurse:() ~force:() ~kill:()
      Fpath.(
        more_paths
        @ [
            fetch / "dkml-compiler";
            fetch / "dkml-runtime-common";
            fetch / "dkml-runtime-distribution";
            fetch / "dksdk-access";
            fetch / "dksdk-ffi-c";
            fetch / "dksdk-ffi-java";
            fetch / "dksdk-ffi-ocaml";
            fetch / "dksdk-opam-repository-core";
            fetch / "dksdk-opam-repository-js";
            fetch / "ocaml-backend";
          ])
    |> rmsg
  end;
  if List.mem `DkSdkCMake areas then begin
    start_step "Cleaning SonicScoutAndroid dksdk-cmake source code";
    DkFs_C99.Path.rm ~recurse:() ~force:() ~kill:()
      Fpath.[ fetch / "dksdk-cmake" ]
    |> rmsg
  end;
  if List.mem `MavenRepository areas then begin
    start_step "Cleaning Maven repositories (Java artifacts for DkSDK only)";
    let m2repo =
      if Sys.win32 then
        Fpath.(v (Sys.getenv "USERPROFILE") / ".m2" / "repository")
      else Fpath.(v (Sys.getenv "HOME") / ".m2" / "repository")
    in
    DkFs_C99.Path.rm ~recurse:() ~force:() ~kill:()
      Fpath.
        [
          m2repo / "com" / "diskuv" / "dksdk" / "core";
          m2repo / "com" / "diskuv" / "dksdk" / "ffi";
        ]
    |> rmsg
  end;
  if List.mem `AndroidBuilds areas then begin
    start_step "Cleaning SonicScoutAndroid build artifacts";
    DkFs_C99.Path.rm ~recurse:() ~force:() ~kill:()
      Fpath.
        [
          projectdir / ".ci";
          projectdir / ".gradle";
          projectdir / "local.properties";
          projectdir / "dkconfig" / "build";
          projectdir / "data" / ".cxx";
          projectdir / "data" / "build";
          projectdir / "app" / "build";
          projectdir // user_presets_relfile;
        ]
    |> rmsg;
    let ffijava = Fpath.(fetch / "dksdk-ffi-java") in
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
  end;
  if Sys.win32 && List.mem `DkSdkWsl2 areas then begin
    start_step "Cleaning SonicScoutAndroid build artifacts referencing DkSDK WSL2";
    (* Avoids:
        [CXX1409]
        C:\scoutapps\us\SonicScoutAndroid\data\.cxx\Debug\5b4k3l6q\arm64-v8a\android_gradle_build.json
        debug|arm64-v8a :
        expected buildFiles file
        '\\wsl.localhost\DkSDK-1.0-Debian-12-NDK-23.1.7779620\home\dksdkbob\source\34880665\build\_deps\c-capnproto-src\CMakeLists.txt'
        to exist *)
    DkFs_C99.Path.rm ~recurse:() ~force:() ~kill:()
      Fpath.
        [
          projectdir / "data" / ".cxx";
        ]
    |> rmsg;
  end;
  RunGradle.clean areas

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
      Utils.dk_ninja_link_or_copy ~dk;
      dk [ "dksdk.java.jdk.download"; "NO_SYSTEM_PATH"; "JDK"; "8" ];
      dk [ "dksdk.java.jdk.download"; "NO_SYSTEM_PATH"; "JDK"; "17" ];
      if Sys.win32 then
        Logs.info (fun l ->
            l "NOTE: Extracting Gradle can take several minutes");
      dk [ "dksdk.gradle.download"; "ALL"; "NO_SYSTEM_PATH" ];

      (* Packages: NDK (Side by side) + Android SDK Platform *)
      dk [ "dksdk.android.ndk.download"; "NO_SYSTEM_PATH" ];
      (* Package: Google APIs Intel x86_64 Atom System Image *)
      dk
        [
          "dksdk.android.pkg.download";
          "PACKAGE";
          (* Encode [system-images;android-31;google_apis;x86_64] *)
          "system-images#android-31#google_apis#x86_64";
        ];
      (* Package: Android Emulator *)
      dk [ "dksdk.android.pkg.download"; "PACKAGE"; "emulator" ];
      (* Package: Android SDK Platform-Tools (not the same as Android SDK Platform!) *)
      dk [ "dksdk.android.pkg.download"; "PACKAGE"; "platform-tools" ];

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
