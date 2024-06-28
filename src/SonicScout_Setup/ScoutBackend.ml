open Utils
open Bos

let builddir_name = "build_dev"

let clean areas =
  let cwd = OS.Dir.current () |> rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in
  if List.mem `DkSdkSourceCode areas then begin
    start_step "Cleaning SonicScoutBackend DkSDK source code";
    OS.Dir.delete ~recurse:true Fpath.(projectdir / "fetch" / "dkml-compiler")
    |> rmsg;
    OS.Dir.delete ~recurse:true
      Fpath.(projectdir / "fetch" / "dkml-runtime-common")
    |> rmsg;
    OS.Dir.delete ~recurse:true
      Fpath.(projectdir / "fetch" / "dkml-runtime-distribution")
    |> rmsg;
    OS.Dir.delete ~recurse:true Fpath.(projectdir / "fetch" / "dksdk-access")
    |> rmsg;
    OS.Dir.delete ~recurse:true Fpath.(projectdir / "fetch" / "dksdk-cmake")
    |> rmsg;
    OS.Dir.delete ~recurse:true Fpath.(projectdir / "fetch" / "dksdk-ffi-c")
    |> rmsg;
    OS.Dir.delete ~recurse:true Fpath.(projectdir / "fetch" / "dksdk-ffi-java")
    |> rmsg;
    OS.Dir.delete ~recurse:true Fpath.(projectdir / "fetch" / "dksdk-ffi-ocaml")
    |> rmsg
  end;
  if List.mem `Builds areas then begin
    start_step "Cleaning SonicScoutBackend build artifacts";
    OS.Dir.delete ~recurse:true Fpath.(projectdir / builddir_name) |> rmsg
  end

let package ~notarize () =
  start_step "Packaging SonicScoutBackend";
  let cwd = OS.Dir.current () |> rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in
  let builddir = Fpath.(projectdir / builddir_name) in
  let tools_dir = Qt.tools_dir ~projectdir in
  match Tr1HostMachine.abi with
  | `darwin_x86_64 | `darwin_arm64 ->
      let env =
        if notarize then
          Some (OS.Env.current () |> rmsg |> OSEnvMap.(add "SCOUT_NOTARIZE" "1"))
        else None
      in
      (* TODO: Use https://cmake.org/cmake/help/latest/cpack_gen/external.html.
         We only use [TGZ] so the intermediate .dmg is produced. Any generator
         can do that. Or just do a plain [cmake --install]. *)
      RunCPack.run ?env ~projectdir ~builddir [ "-G"; "TGZ" ];
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
        RunCMake.run ~projectdir
          [
            "-D";
            "URI=https://github.com/Kitware/CMake/releases/download/v3.30.0-rc4/cmake-3.30.0-rc4-windows-x86_64.zip";
            "-D";
            Fmt.str "FILENAME=%a" Fpath.pp cmake_zip;
            "-P";
            Filename.concat (Tr1Assets.LocalDir.v ()) "download.cmake";
          ];
        let actual_sha256 = cksum_file ~m:(module Digestif.SHA256) cmake_zip in
        if
          "9086fa9c83e5a3da2599220d4e426d1dfeefac417f2abf19862a91620c38faee"
          <> actual_sha256
        then
          failwith
            ("The SHA256 checksums for cmake 3.30.0-rc4 did not match. Actual: "
           ^ actual_sha256);
        OS.Cmd.run
          Cmd.(
            v (if Sys.win32 then "powershell.exe" else "pwsh")
            % "-NoProfile" % "-InputFormat" % "None" % "-ExecutionPolicy"
            % "Bypass" % "-File"
            % Filename.concat (Tr1Assets.LocalDir.v ()) "unzip.ps1"
            % Fpath.to_string cmake_zip % Fpath.to_string tools_dir)
        |> rmsg);

      (* Run CPack with ZIP *)
      let env =
        OS.Env.current () |> rmsg
        |> OSEnvMap.(add "WIX" (Fpath.to_string wixdir))
      in
      RunCPack.run ~cpack:cpack_new ~env ~projectdir ~builddir
        [ "-G"; "ZIP"; "-D"; Fmt.str "CPACK_WIX_VERSION=%d" wixmajorver ];

      Logs.app (fun l ->
          l "The Windows .msi for publishing is at %a" Fpath.pp
            Fpath.(builddir / "SonicScoutBackend-1.0.0-win64.msi"))
  | _ -> failwith "Currently your host machine is not supported by Sonic Scout"

let run ~next () =
  start_step "Building SonicScoutBackend";
  let cwd = OS.Dir.current () |> rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in
  let dk_env = dk_env ~next in
  let dk = dk ~env:dk_env in
  let preset =
    match Tr1HostMachine.abi with
    | `darwin_x86_64 -> "dev-AppleIntel"
    | `darwin_arm64 ->
        (* We would like [dev-AppleSilicon]. But only Qt6.2.0+ are universal binaries!
           So until the manager app (SonicScoutBackend) has an upgrade to Qt6, we are stuck with Rosetta emulation. *)
        "dev-AppleIntel"
    | `windows_x86_64 -> "dev-Windows64"
    | `linux_x86_64 -> "dev-Linux-x86_64"
    | _ ->
        failwith "Currently your host machine is not supported by Sonic Scout"
  in
  OS.Dir.with_current projectdir
    (fun () ->
      dk [ "dksdk.project.get" ];
      dk [ "dksdk.cmake.link"; "QUIET" ];
      (* You can ignore the error if you got 'failed to create symbolic link' for dksdk.ninja.link *)
      dk [ "dksdk.ninja.link"; "QUIET" ];
      let user_presets = Fpath.v "CMakeUserPresets.json" in
      if not (OS.File.exists user_presets |> rmsg) then
        OS.File.write user_presets
          (OS.File.read (Fpath.v "CMakeUserPresets-SUGGESTED.json") |> rmsg)
        |> rmsg;

      RunCMake.run ~projectdir [ "--preset"; preset ];
      RunCMake.run ~projectdir
        [
          "--build";
          builddir_name;
          "--target";
          "main-cli";
          "DkSDK_DevTools";
          "DkSDKTest_UnitTests_ALL";
          "ManagerApp_ALL";
        ])
    ()
  |> rmsg
