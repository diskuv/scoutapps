open Utils
open Bos

let builddir_name = "build_dev"

let clean areas =
  let cwd = OS.Dir.current () |> rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in
  if List.mem `DkSdkSourceCode areas then begin
    start_step "Cleaning SonicScoutBackend DkSDK source code";
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

let run ~next () =
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
        ];

      if preset <> "" then assert false)
    ()
  |> rmsg
