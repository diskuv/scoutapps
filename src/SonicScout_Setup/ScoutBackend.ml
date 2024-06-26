open Utils
open Bos

let clean () =
  let cwd = OS.Dir.current () |> rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in
  OS.Dir.delete ~recurse:true Fpath.(projectdir / "build_dev") |> rmsg

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

      if preset <> "" then assert false)
    ()
  |> rmsg
