open Utils

let sqlite3_dir ~projectdir = Fpath.(Qt.tools_dir ~projectdir / "sqlite3")

let sqlite3_bin ~projectdir =
  Fpath.(
    sqlite3_dir ~projectdir / if Sys.win32 then "sqlite3.exe" else "sqlite3")

(** This does a local install of Sqlite3. *)
let install_sqlite3 ~projectdir ~os ~cpu ~sha3_256 =
  let open Bos in
  let tools_dir = Qt.tools_dir ~projectdir in
  let sqlite3_dir = sqlite3_dir ~projectdir in
  let sqlite3_bin = sqlite3_bin ~projectdir in
  if not (OS.File.exists sqlite3_bin |> rmsg) then (
    let (_created : bool) = OS.Dir.create tools_dir |> rmsg in
    let zip = Fpath.(tools_dir / "sqlite-tools.zip") in
    let uri =
      Fmt.str "https://www.sqlite.org/2024/sqlite-tools-%s-%s-3460000.zip" os
        cpu
    in
    Lwt_main.run
    @@ DkNet_Std.Http.download_uri ~max_time_ms:300_000
         ~checksum:(`SHA3_256 sha3_256) ~destination:zip (Uri.of_string uri);
    if Sys.win32 then
      OS.Cmd.run
        Cmd.(
          v (if Sys.win32 then "powershell.exe" else "pwsh")
          % "-NoProfile" % "-InputFormat" % "None" % "-ExecutionPolicy"
          % "Bypass" % "-File"
          % Filename.concat (Tr1Assets.LocalDir.v ()) "unzip.ps1"
          % Fpath.to_string zip
          % Fpath.to_string sqlite3_dir)
      |> rmsg
    else
      OS.Cmd.run
        Cmd.(
          v "unzip" % Fpath.to_string zip % "-d" % Fpath.to_string sqlite3_dir)
      |> rmsg)

let run () =
  start_step "Installing Sqlite3";
  let open Bos in
  let cwd = OS.Dir.current () |> rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in
  match Tr1HostMachine.abi with
  | `darwin_x86_64 | `darwin_arm64 ->
      install_sqlite3 ~projectdir ~os:"osx" ~cpu:"x64"
        ~sha3_256:
          "99e2b1014211151e94d6ce0c91de03494bc8d3b749a739af120f5387effe5de8"
  | `windows_x86_64 ->
      install_sqlite3 ~projectdir ~os:"win" ~cpu:"x64"
        ~sha3_256:
          "a0cf6a21509210d931f1f174fe68cbfaa1979d555158efdc059a5171ce108e1a"
  | `linux_x86_64 ->
      install_sqlite3 ~projectdir ~os:"linux" ~cpu:"x64"
        ~sha3_256:
          "7ba6ea0d94e7b945b22e98cc306220e35156a34fe6e7a370beb88580569a4caf"
  | _ -> failwith "Currently your host machine is not supported by Sonic Scout"
