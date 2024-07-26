open Utils

(** This does a global install of Miniconda3. We could do a local
    install using the {{:https://docs.conda.io/projects/conda/en/latest/user-guide/install/windows.html}user guide}
    but it seems like overkill for Windows (where we already do
    a global install of DkML). *)
let install_win32_miniconda3 () =
  let open Bos in
  if OS.Cmd.exists Cmd.(v "conda") |> rmsg then None
  else begin
    Winget.install [ "-e"; "--id"; "Anaconda.Miniconda3" ];
    Some
      Fpath.(
        v (Sys.getenv "USERPROFILE") / "miniconda3" / "Scripts" / "conda.exe")
  end

let tools_dir ~projectdir = Fpath.(projectdir / ".tools")
let miniconda_dir ~projectdir = Fpath.(tools_dir ~projectdir / "miniconda")

let activate_sh ~projectdir =
  Fpath.(miniconda_dir ~projectdir / "bin" / "activate")

(** This does a local install of Miniconda3. *)
let install_unix_miniconda3 ~projectdir ~platform ~sha256 =
  (* https://docs.conda.io/projects/conda/en/latest/user-guide/install/macos.html.
     But we do not run 'conda init --all' which is just unwanted shellscript
     integration. *)
  let open Bos in
  let tools_dir = tools_dir ~projectdir in
  let miniconda_dir = miniconda_dir ~projectdir in
  let activate_sh = activate_sh ~projectdir in
  if not (OS.File.exists activate_sh |> rmsg) then (
    let (_created : bool) = OS.Dir.create tools_dir |> rmsg in
    let latest_sh = Fpath.(tools_dir / "Miniconda3.sh") in
    let uri =
      Fmt.str
        "https://repo.anaconda.com/miniconda/Miniconda3-py312_24.4.0-0-%s.sh"
        platform
    in
    Lwt_main.run
    @@ DkNet_Std.Http.download_uri ~max_time_ms:300_000 ~destination:latest_sh
         ~checksum:(`SHA_256 sha256) (Uri.of_string uri);
    OS.Cmd.run Cmd.(v "/bin/bash" % p latest_sh % "-b" % "-p" % p miniconda_dir)
    |> rmsg);
  None

let run_conda ~conda_exe ~projectdir args =
  let open Bos in
  let conda_exe, conda_str =
    match conda_exe with
    | Some exe -> (Cmd.(v (p exe)), Fpath.to_string exe)
    | None -> (Cmd.v "conda", "conda")
  in
  let env = OS.Env.current () |> rmsg in
  (* We disable any global/user pip config file. Sometimes private
     repository credentials are needed in a users' pip configuration,
     but here we only use public repositories.
     https://pip.pypa.io/en/stable/topics/configuration/ *)
  if Sys.win32 then
    OS.Cmd.run
      ~env:OSEnvMap.(add "PIP_CONFIG_FILE" "nul" env)
      Cmd.(conda_exe %% of_list args)
    |> rmsg
  else
    OS.Cmd.run
      ~env:OSEnvMap.(add "PIP_CONFIG_FILE" "/dev/null" env)
      Cmd.(
        v "/bin/bash" % "-c"
        % Fmt.str "source '%a' && %s" Fpath.pp (activate_sh ~projectdir)
            (Filename.quote_command conda_str args))
    |> rmsg

let run_conda_string ~conda_exe ~projectdir args =
  let open Bos in
  let conda_exe, conda_str =
    match conda_exe with
    | Some exe -> (Cmd.(v (p exe)), Fpath.to_string exe)
    | None -> (Cmd.v "conda", "conda")
  in
  let env = OS.Env.current () |> rmsg in
  if Sys.win32 then
    OS.Cmd.run_out
      ~env:OSEnvMap.(add "PIP_CONFIG_FILE" "nul" env)
      Cmd.(conda_exe %% of_list args)
    |> OS.Cmd.out_string ~trim:true
    |> rmsg |> fst
  else
    OS.Cmd.run_out
      ~env:OSEnvMap.(add "PIP_CONFIG_FILE" "/dev/null" env)
      Cmd.(
        v "/bin/bash" % "-c"
        % Fmt.str "source '%a' && %s" Fpath.pp (activate_sh ~projectdir)
            (Filename.quote_command conda_str args))
    |> OS.Cmd.out_string ~trim:true
    |> rmsg |> fst

let run () =
  start_step "Installing Qt";
  let open Bos in
  let cwd = OS.Dir.current () |> rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in
  let conda_exe =
    match Tr1HostMachine.abi with
    | `darwin_x86_64 ->
        install_unix_miniconda3 ~projectdir ~platform:"MacOSX-x86_64"
          ~sha256:
            "1413369470adb7cf52f8b961e81b3ceeb92f5931a451bef9cb0c42be0ce17ef3"
    | `darwin_arm64 ->
        install_unix_miniconda3 ~projectdir ~platform:"MacOSX-arm64"
          ~sha256:
            "f4925c0150d232d95de798a64c696f4b2df2745bb997b793506bdfd27bf91e11"
    | `windows_x86_64 | `windows_x86 -> install_win32_miniconda3 ()
    | `linux_x86_64 ->
        install_unix_miniconda3 ~projectdir ~platform:"Linux-x86_64"
          ~sha256:
            "b6597785e6b071f1ca69cf7be6d0161015b96340b9a9e132215d5713408c3a7c"
    | _ ->
        failwith "Currently your host machine is not supported by Sonic Scout"
  in
  (* Check if Conda already has an [aqt] environment *)
  let env_list_j_content =
    run_conda_string ~conda_exe ~projectdir [ "env"; "list"; "--json" ]
  in
  let env_list_j = Ezjsonm.from_string env_list_j_content in
  let envs = Ezjsonm.find env_list_j [ "envs" ] |> Ezjsonm.get_strings in
  let has_aqt =
    List.exists (fun s -> "aqt" = (Fpath.v s |> Fpath.basename)) envs
  in
  (* Create Python environment with packages *)
  if not has_aqt then
    run_conda ~conda_exe ~projectdir
      [
        "env";
        "create";
        "-f";
        Fpath.to_string
          Fpath.(projectdir / "dependencies" / "zxing" / "environment.yml");
      ];
  (* https://aqtinstall.readthedocs.io/en/latest/getting_started.html

     Cheatsheet:

     $ (source us/SonicScoutBackend/.tools/miniconda/bin/activate && conda run -n aqt aqt list-qt mac desktop --arch 5.15.2)
     clang_64 wasm_32
  *)
  let host, target =
    match Tr1HostMachine.abi with
    | `darwin_x86_64 | `darwin_arm64 -> ("mac", "clang_64")
    | `windows_x86_64 | `windows_x86 -> ("windows", "win64_msvc2019_64")
    | `linux_x86_64 -> ("linux", "gcc_64")
    | _ ->
        failwith "Currently your host machine is not supported by Sonic Scout"
  in
  let qt5_ver = "5.15.2" in
  if not (OS.Dir.exists Fpath.(projectdir / qt5_ver) |> rmsg) then begin
    Logs.info (fun l ->
        l "Installing Qt modules. This may take %s minutes ..."
          (if Sys.win32 then "several" else "a few"));
    run_conda ~conda_exe ~projectdir
      [
        "run";
        (* Do not use "--live-stream"; since stalls on Win32 and may corrupt terminal *)
        "-n";
        "aqt";
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
      ]
  end
