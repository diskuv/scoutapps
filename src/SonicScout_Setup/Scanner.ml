open Utils

let run ~slots () =
  let open Bos in
  ignore slots;
  start_step "Running QR code scanner";
  let cwd = OS.Dir.current () |> rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in

  (* Find locations *)
  let scanner_projectrel_exe =
    let subpath =
      match Tr1HostMachine.os with
      | `IOS | `OSX ->
          Fpath.(
            v "SonicScoutQRScanner.app"
            / "Contents" / "MacOS" / "SonicScoutQRScanner")
      | `Windows -> Fpath.(v "SonicScoutQRScanner.exe")
      | _ -> Fpath.(v "SonicScoutQRScanner")
    in
    Fpath.(
      ScoutBackend.build_reldir / "src" / "SonicScout_ManagerApp" // subpath)
  in
  let { host = _; target = _; qt5_ver; subdir } : Qt.qt_locations =
    Qt.qt_locations ()
  in

  (* Clone the scanner if necessary *)
  let scanner_exe, scanner_projectrel_dir =
    match Tr1HostMachine.os with
    | `IOS | `OSX ->
        (* Since we will be changing the executable with
           [install_name_tool] later, we clone the file.

           And we choose a location so the @executable_path/... does not have
           a zillion [".."] in it. *)
        let dest_projectrel =
          Fpath.(ScoutBackend.build_reldir / "SonicScoutQRScanner")
        in
        let dest = Fpath.(projectdir // dest_projectrel) in
        DkFs_C99.File.copy
          ~src:Fpath.(projectdir // scanner_projectrel_exe)
          ~dest ()
        |> rmsg;
        Unix.chmod (Fpath.to_string dest) 0o700;
        (dest, Fpath.parent dest_projectrel)
    | _ ->
        ( Fpath.(projectdir // scanner_projectrel_exe),
          Fpath.parent scanner_projectrel_exe )
  in

  (* Make Qt5 shared libraries available. *)
  let qt_bin = Fpath.(projectdir / qt5_ver / subdir / "bin") in
  let qt_projectrel_lib = Fpath.(v qt5_ver / subdir / "lib") in
  let env = OS.Env.current () |> rmsg in
  let env =
    match Tr1HostMachine.os with
    | `IOS | `OSX ->
        (* Need Qt5 .so available to RPATH *)
        let ancestors_to_projectdir =
          String.concat "/"
            (Fpath.segs scanner_projectrel_dir
            |> List.filter_map (function "" -> None | _ -> Some ".."))
        in
        let exepath =
          Printf.sprintf "@executable_path/%s/%s" ancestors_to_projectdir
            (Fpath.to_string qt_projectrel_lib)
        in
        (* run: install_name_tool -add_rpath @executable_path/../../../lib /x/y/z/SonicScoutQRScanner *)
        OS.Cmd.run
          Cmd.(v "install_name_tool" % "-add_rpath" % exepath % p scanner_exe)
        |> rmsg;
        env
    | `Windows ->
        (* Add the Qt5 DLLs (Windows) to the PATH *)
        let entry =
          let path_sep = if Sys.win32 then ";" else ":" in
          match OSEnvMap.find_opt "PATH" env with
          | Some v ->
              Printf.sprintf "%s%s%s" (Fpath.to_string qt_bin) path_sep v
          | None -> Fpath.to_string qt_bin
        in
        OSEnvMap.add "PATH" entry env
    | _ -> env
  in

  (* Run the scanner *)
  OS.Cmd.run ~env Cmd.(v (p scanner_exe)) |> rmsg
