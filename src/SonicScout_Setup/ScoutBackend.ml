open Bos

let build_reldir = Fpath.v "build_dev"
let user_presets_relfile = Fpath.v "CMakeUserPresets.json"

let clean areas =
  let open Utils in
  let cwd = OS.Dir.current () |> rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in
  Qt.clean areas;
  if List.mem `DkSdkSourceCode areas then begin
    start_step "Cleaning SonicScoutBackend DkSDK source code";
    DkFs_C99.Path.rm ~recurse:() ~force:() ~kill:()
      Fpath.
        [
          projectdir / "fetch" / "dkml-compiler";
          projectdir / "fetch" / "dkml-runtime-common";
          projectdir / "fetch" / "dkml-runtime-distribution";
          projectdir / "fetch" / "dksdk-access";
          projectdir / "fetch" / "dksdk-cmake";
          projectdir / "fetch" / "dksdk-ffi-c";
          projectdir / "fetch" / "dksdk-ffi-ocaml";
        ]
    |> rmsg
  end;
  if List.mem `DkSdkCMake areas then begin
    start_step "Cleaning SonicScoutBackend dksdk-cmake source code";
    DkFs_C99.Path.rm ~recurse:() ~force:() ~kill:()
      Fpath.[ projectdir / "fetch" / "dksdk-cmake" ]
    |> rmsg
  end;
  if List.mem `BackendBuilds areas then begin
    start_step
      "Cleaning SonicScoutBackend build artifacts (this may take tens of \
       minutes)";
    DkFs_C99.Path.rm ~recurse:() ~force:() ~kill:()
      Fpath.
        [
          projectdir // build_reldir;
          projectdir / "_build";
          projectdir / ".tools";
          projectdir // user_presets_relfile;
        ]
    |> rmsg
  end

let package ~notarize () =
  let open Utils in
  start_step "Packaging SonicScoutBackend";
  let cwd = OS.Dir.current () |> rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in
  let builddir = Fpath.(projectdir // build_reldir) in
  let tools_dir = Qt.tools_dir ~projectdir in
  match Tr1HostMachine.abi with
  | `darwin_x86_64 | `darwin_arm64 ->
      let env = OS.Env.current () |> rmsg in
      let env =
        if notarize then env |> OSEnvMap.(add "SCOUT_NOTARIZE" "1") else env
      in
      let env =
        match Logs.level () with
        | Some Logs.Debug -> env |> OSEnvMap.(add "SCOUT_VERBOSE" "2")
        | _ -> env
      in
      (* TODO: Use https://cmake.org/cmake/help/latest/cpack_gen/external.html.
         We only use [TGZ] so the intermediate .dmg is produced. Any generator
         can do that. Or just do a plain [cmake --install]. *)
      RunCPack.run ~env ~projectdir ~builddir [ "-G"; "TGZ" ];
      let dmg =
        Fpath.(
          builddir / "_CPack_Packages" / "Darwin" / "TGZ"
          / "SonicScoutBackend-1.0.0-Darwin" / "SonicScoutQRScanner.dmg")
      in
      Logs.app (fun l -> l "The macOS dmg for publishing is at %a" Fpath.pp dmg)
  | `windows_x86_64 | `windows_x86 | `windows_arm32 | `windows_arm64 ->
      let default_search =
        OS.Cmd.search_path_dirs (Sys.getenv "PATH") |> rmsg
      in

      (* > The wix.exe tool requires the .NET SDK, version 6 or later. *)
      (* https://learn.microsoft.com/en-us/dotnet/core/install/windows#install-the-sdk *)
      Winget.install [ "Microsoft.DotNet.SDK.8" ];

      (* Install WiX in local path and don't add to PATH.
         Confer: https://cmake.org/cmake/help/latest/cpack_gen/wix.html *)
      let wixdir = Fpath.(tools_dir / "wix") in
      let wixmajorver = 4 in
      let wixver = "4.0.5" in
      let dotnet =
        (* If just installed, it will not be in the PATH. *)
        OS.Cmd.get_tool
          ~search:Fpath.(v {|C:\Program Files\dotnet|} :: default_search)
          Cmd.(v "dotnet")
        |> rmsg
      in
      OS.Cmd.run
        Cmd.(
          v (p dotnet)
          % "tool" % "install" % "--tool-path" % p wixdir % "wix" % "--version"
          % wixver)
      |> rmsg;

      (* Add WiX UI extension. The [--global] installs to USERPROFILE.
         Confer: https://cmake.org/cmake/help/latest/cpack_gen/wix.html *)
      let wix = Fpath.(wixdir / "wix.exe") in
      OS.Cmd.run
        Cmd.(
          v (p wix)
          % "extension" % "add" % "--global"
          % Fmt.str "WixToolset.UI.wixext/%s" wixver)
      |> rmsg;

      (* Sigh. Hadn't realized that WIX version 4 requires CPack 3.30+
         until too late. So just download a newer CPack. *)
      let cpack_new =
        Fpath.(
          tools_dir / "cmake-3.30.0-rc4-windows-x86_64" / "bin" / "cpack.exe")
      in
      if not (OS.File.exists cpack_new |> rmsg) then (
        let cmake_zip = Fpath.(tools_dir / "cmake.zip") in
        (* https://github.com/Kitware/CMake/releases/download/v3.30.0-rc4/cmake-3.30.0-rc4-windows-x86_64.zip *)
        Lwt_main.run
        @@ DkNet_Std.Http.download_uri ~max_time_ms:300_000
             ~checksum:
               (`SHA_256
                 "9086fa9c83e5a3da2599220d4e426d1dfeefac417f2abf19862a91620c38faee")
             ~destination:cmake_zip
             (Uri.of_string
                "https://github.com/Kitware/CMake/releases/download/v3.30.0-rc4/cmake-3.30.0-rc4-windows-x86_64.zip");
        OS.Cmd.run
          Cmd.(
            v (if Sys.win32 then "powershell.exe" else "pwsh")
            % "-NoProfile" % "-InputFormat" % "None" % "-ExecutionPolicy"
            % "Bypass" % "-File"
            % Filename.concat (Tr1Assets.LocalDir.v ()) "unzip.ps1"
            % Fpath.to_string cmake_zip % Fpath.to_string tools_dir)
        |> rmsg);

      (* Run CPack with WIX *)
      let env =
        OS.Env.current () |> rmsg
        |> OSEnvMap.(add "WIX" (Fpath.to_string wixdir))
      in
      RunCPack.run ~cpack:cpack_new ~env ~projectdir ~builddir
        [ "-G"; "WIX"; "-D"; Fmt.str "CPACK_WIX_VERSION=%d" wixmajorver ];

      Logs.app (fun l ->
          l "The Windows .msi for publishing is at %a" Fpath.pp
            Fpath.(builddir / "SonicScoutBackend-1.0.0-win64.msi"))
  | _ -> failwith "Currently your host machine is not supported by Sonic Scout"

let cmake_properties ~cwd ~(opts : Utils.opts) slots : string list =
  let cprops =
    match Slots.msys2 slots with
    | Some fpath -> [ Fmt.str "-DDKSDK_MSYS2_DIR=%a" Fpath.pp fpath ]
    | None -> []
  in
  let cprops =
    Fmt.str "-DCMAKE_BUILD_TYPE=%s"
      (match opts.build_type with `Debug -> "Debug" | `Release -> "Release")
    :: cprops
  in
  let open Utils in
  let cprops =
    match opts with
    | { fetch_siblings = true; _ } ->
        (* Override what is forced in CMakePresets.json *)
        let sib project =
          let project_upcase = String.uppercase_ascii project in
          Fmt.str "-DFETCHCONTENT_SOURCE_DIR_%s=%s" project_upcase
            (Utils.sibling_dir_mixed ~cwd ~project)
        in
        sib "dkml-runtime-common"
        :: sib "dkml-runtime-distribution"
        :: sib "dkml-compiler" :: sib "dksdk-access" :: sib "dksdk-cmake"
        :: cprops
    | { fetch_siblings = false; _ } -> cprops
  in
  cprops

let run ?(opts = Utils.default_opts) ?global_dkml ~slots () =
  let open Utils in
  start_step "Building SonicScoutBackend";
  let cwd = OS.Dir.current () |> rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in
  let dk_env = dk_env ~opts () in
  let dk = dk ~env:dk_env in
  let preset =
    match (Tr1HostMachine.abi, global_dkml) with
    | `darwin_x86_64, _ -> "dev-AppleIntel"
    | `darwin_arm64, _ ->
        (* We would like [dev-AppleSilicon]. But only Qt6.2.0+ are universal binaries!
           So until the manager app (SonicScoutBackend) has an upgrade to Qt6, we are stuck with Rosetta emulation. *)
        "dev-AppleIntel"
    | `windows_x86_64, Some () ->
        (* We get the Qt scanning application abort in caml_startup() if we mix and match DkML
           with Visual Studio of RunCMake. Instead use local OCaml (no DkML). *)
        "dev-Windows64"
    | `windows_x86_64, None ->
        (* We get the Qt scanning application abort in caml_startup() if we mix and match DkML
           with Visual Studio of RunCMake. So use local OCaml (no DkML). *)
        "dev-Windows64-with-localocaml"
    | `linux_x86_64, _ -> "dev-Linux-x86_64"
    | _ ->
        failwith "Currently your host machine is not supported by Sonic Scout"
  in
  OS.Dir.with_current projectdir
    (fun () ->
      dk ~slots [ "dksdk.project.get" ];
      dk ~slots [ "dksdk.cmake.link"; "QUIET" ];
      Utils.dk_ninja_link_or_copy ~dk:(dk ~slots);
      let user_presets = Fpath.v "CMakeUserPresets.json" in
      if not (OS.File.exists user_presets |> rmsg) then
        OS.File.write user_presets
          (OS.File.read (Fpath.v "CMakeUserPresets-SUGGESTED.json") |> rmsg)
        |> rmsg;

      RunCMake.run ?global_dkml ~projectdir ~name:"backend-preset" ~slots
        ([ "--preset"; preset ] @ cmake_properties ~cwd ~opts slots);
      RunCMake.run ?global_dkml ~projectdir ~name:"backend-build" ~slots
        [
          "--build";
          Fpath.to_string build_reldir;
          "--target";
          "main-cli";
          "DkSDK_DevTools";
          "DkSDKTest_UnitTests_ALL";
          "ManagerApp_ALL";
          "SquirrelScout_ObjsLib";
        ])
    ()
  |> rmsg;
  slots
