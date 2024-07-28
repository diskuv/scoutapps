open Utils

let run ~slots () =
  let open Bos in
  ignore slots;
  start_step "Running QR code scanner";
  let cwd = OS.Dir.current () |> rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in

  (* Find locations *)
  let scanner_exe =
    Fpath.(
      projectdir // ScoutBackend.build_reldir / "src" / "ManagerApp"
      / "SonicScoutQRScanner.exe")
  in
  let { host = _; target = _; qt5_ver; subdir } : Qt.qt_locations =
    Qt.qt_locations ()
  in

  (* Add the Qt5 DLLs (Windows) to the PATH *)
  let qt_bin = Fpath.(projectdir / qt5_ver / subdir / "bin") in
  let env = OS.Env.current () |> rmsg in
  let env_PATH =
    let path_sep = if Sys.win32 then ";" else ":" in
    match OSEnvMap.find_opt "PATH" env with
    | Some v -> Printf.sprintf "%s%s%s" (Fpath.to_string qt_bin) path_sep v
    | None -> Fpath.to_string qt_bin
  in
  let env = OSEnvMap.add "PATH" env_PATH env in

  (* Run the scanner *)
  OS.Cmd.run ~env Cmd.(v (p scanner_exe)) |> rmsg
