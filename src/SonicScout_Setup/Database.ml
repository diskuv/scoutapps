open Utils

let run ~slots () =
  let open Bos in
  ignore slots;
  start_step "Running sqlite3 database shell";
  let cwd = OS.Dir.current () |> rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in

  (* Find locations *)
  let sqlite3_exe =
    let exe_ext = if Sys.win32 then ".exe" else "" in
    Fpath.(projectdir / ".tools" / "sqlite3" / ("sqlite3" ^ exe_ext))
  in
  let xdg = Xdg.create ~env:Sys.getenv_opt () in
  let sqlite3_db =
    Fpath.(v (Xdg.data_dir xdg) / "sonic-scout" / "sqlite3.db")
  in

  (* Run the scanner *)
  OS.Cmd.run
    Cmd.(
      v (p sqlite3_exe)
      % "-cmd" % ".schema" % "-csv" % "-header" % "-readonly" % "-safe"
      % p sqlite3_db)
  |> rmsg
