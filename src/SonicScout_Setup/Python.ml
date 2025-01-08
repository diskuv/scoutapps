let tools_dir ~projectdir = Fpath.(projectdir / ".tools")
let uv_dir ~projectdir = Fpath.(tools_dir ~projectdir / "uv")

let install_uv ~slots () =
  let open Bos in
  let cwd = OS.Dir.current () |> Utils.rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in
  let tools_dir = tools_dir ~projectdir in
  let uv_dir = uv_dir ~projectdir in
  let (_created : bool) = OS.Dir.create uv_dir |> Utils.rmsg in
  let checksum, tag, archive, uv_exe =
    match Tr1HostMachine.abi with
    | `windows_x86_64 ->
        ( "ee2468e40320a0a2a36435e66bbd0d861228c4c06767f22d97876528138f4ba0",
          "x86_64-pc-windows-msvc",
          `ZipWin32,
          "uv.exe" )
    | `windows_x86 ->
        ( "2ea709cf816b70661c6aa43d6aff7526faebafc2d45f7167d3192c5b9bb0a28f",
          "i686-pc-windows-msvc",
          `ZipWin32,
          "uv.exe" )
    | `darwin_arm64 ->
        ( "d548dffc256014c4c8c693e148140a3a21bcc2bf066a35e1d5f0d24c91d32112",
          "aarch64-apple-darwin",
          `TarGz,
          "uv" )
    | `darwin_x86_64 ->
        ( "8caf91b936ede1167abaebae07c2a1cbb22473355fa0ad7ebb2580307e84fb47",
          "x86_64-apple-darwin",
          `TarGz,
          "uv" )
    | `linux_x86_64 ->
        ( "22034760075b92487b326da5aa1a2a3e1917e2e766c12c0fd466fccda77013c7",
          "x86_64-unknown-linux-gnu",
          `TarGz,
          "uv" )
    | `linux_x86 ->
        ( "74fd05a1e04bb8c591cb4531d517848d1e2cdc05762ccd291429c165e2a19aa1",
          "i686-unknown-linux-gnu",
          `TarGz,
          "uv" )
    | _ ->
        failwith "Currently your host machine is not supported by Sonic Scout"
  in
  let uv_archive, archive_ext =
    match archive with
    | `ZipWin32 -> (Fpath.(tools_dir / "uv.zip"), ".zip")
    | `TarGz -> (Fpath.(tools_dir / "uv.tar.gz"), ".tar.gz")
  in
  let uv_abs_exe = Fpath.(uv_dir / uv_exe) in
  if OS.File.exists uv_abs_exe |> Utils.rmsg then ()
  else begin
    (* https://github.com/Kitware/CMake/releases/download/v3.30.0-rc4/cmake-3.30.0-rc4-windows-x86_64.zip *)
    Lwt_main.run
    @@ DkNet_Std.Http.download_uri ~max_time_ms:300_000
         ~checksum:(`SHA_256 checksum) ~destination:uv_archive
         (Uri.of_string
            (Printf.sprintf
               "https://github.com/astral-sh/uv/releases/download/0.5.14/uv-%s%s"
               tag archive_ext));
    match archive with
    | `ZipWin32 ->
        OS.Cmd.run
          Cmd.(
            v (if Sys.win32 then "powershell.exe" else "pwsh")
            % "-NoProfile" % "-InputFormat" % "None" % "-ExecutionPolicy"
            % "Bypass" % "-File"
            % Filename.concat (Tr1Assets.LocalDir.v ()) "unzip.ps1"
            % Fpath.to_string uv_archive % Fpath.to_string uv_dir)
        |> Utils.rmsg
    | `TarGz ->
        OS.Dir.with_current uv_dir
          (fun () ->
            OS.Cmd.run Cmd.(v "tar" % "xfz" % Fpath.to_string uv_archive))
          ()
        |> Utils.rmsg |> Utils.rmsg
  end;
  Slots.add_uv ~cache_dir:Fpath.(tools_dir / "uvcache") slots uv_abs_exe

(** [install_python ?version ~slots ()] installs Python.
    
    The default [version] is the oldest "bugfix" Python version as of
    ["2025-01-04"] per {{:https://devguide.python.org/versions/}Status of Python versions}.
    That is Python [3.12], which is the version with the least bugs that still gets
    critical updates. *)
let install_python ?(version = "3.12") ~slots () =
  let open Bos in
  let cwd = OS.Dir.current () |> Utils.rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in
  let tools_dir = tools_dir ~projectdir in
  (* https://docs.astral.sh/uv/concepts/python-versions/#installing-a-python-version *)
  let uv_install_dir = Fpath.(tools_dir / "uvinstall") in
  Utils.uv ~slots
    [
      "python";
      "install";
      version;
      "--install-dir";
      Fpath.to_string uv_install_dir;
    ];
  Slots.add_uv_install ~version slots uv_install_dir

let run ~slots () =
  Utils.start_step "Installing Python";
  let slots = install_uv ~slots () in
  install_python ~slots ()

let __init () =
  let (_ : Slots.t) = run ~slots:(Slots.create ()) () in
  ()
