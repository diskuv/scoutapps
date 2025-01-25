let qt5_ver = "5.15.2"

let clean areas =
  let open Bos in
  let cwd = OS.Dir.current () |> Utils.rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in
  if List.mem `QtInstallation areas then begin
    Utils.start_step "Cleaning SonicScoutBackend Qt installation";
    DkFs_C99.Path.rm ~recurse:() ~force:() ~kill:()
      Fpath.[ projectdir / qt5_ver ]
    |> Utils.rmsg
  end

let tools_dir ~projectdir = Fpath.(projectdir / ".tools")

type qt_locations = {
  host : string;
  target : string;  (** [target] is the `aqt` target to download  *)
  qt5_ver : string;
  subdir : string;
      (** [subdir] is the subdirectory under the QT5 version {!qt5_ver}  *)
}

let qt_locations () =
  let host, target, subdir =
    match Tr1HostMachine.abi with
    | `darwin_x86_64 | `darwin_arm64 -> ("mac", "clang_64", "clang_64")
    | `windows_x86_64 | `windows_x86 ->
        ("windows", "win64_msvc2019_64", "msvc2019_64")
    | `linux_x86_64 -> ("linux", "gcc_64", "gcc_64")
    | _ ->
        failwith "Currently your host machine is not supported by Sonic Scout"
  in
  { host; target; qt5_ver; subdir }

let run ~slots () =
  Utils.start_step "Installing Qt";
  let open Bos in
  let cwd = OS.Dir.current () |> Utils.rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in
  (* https://aqtinstall.readthedocs.io/en/latest/getting_started.html

     Cheatsheet:

     $ (source us/SonicScoutBackend/.tools/miniconda/bin/activate && conda run -n aqt aqt list-qt mac desktop --arch 5.15.2)
     clang_64 wasm_32
  *)
  let { host; target; qt5_ver; subdir = _ } = qt_locations () in
  if not (OS.Dir.exists Fpath.(projectdir / qt5_ver) |> Utils.rmsg) then begin
    Logs.info (fun l ->
        l "Installing Qt modules. This may take %s minutes ..."
          (if Sys.win32 then "several" else "a few"));
    let python_version_args =
      match Slots.python_version slots with
      | None -> []
      | Some python_version -> [ "--python"; python_version ]
    in
    Utils.uv_run ~exclude_newer:"2025-01-04T00:00:00Z" ~slots
      (python_version_args
      @ [
          "--no-project";
          "--with-requirements";
          Fpath.to_string
            Fpath.(projectdir / "dependencies" / "zxing" / "requirements.txt");
          "aqt";
          "install-qt";
          "-O";
          Fpath.to_string projectdir;
          host;
          "desktop";
          qt5_ver;
          target;
          "--base";
          "http://mirrors.ocf.berkeley.edu/qt/";
          "--modules";
          "all";
        ])
  end

let __init () =
  let slots = Slots.create () in
  let slots = Python.run ~slots () in
  run ~slots ()
