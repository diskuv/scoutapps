(* open Utils *)

let find_dkml_win32 () =
  let open Bos in
  (* ex. C:\Users\beckf\AppData\Local\Programs\DkMLNative\bin\dkml.exe *)
  let localappdata = Sys.getenv "LOCALAPPDATA" in
  OS.Cmd.find_tool
    ~search:Fpath.[ v localappdata / "Programs" / "DkMLNative" / "bin" ]
    Cmd.(v "dkml")

let run_win32 ?global_dkml ~slots () =
  let open Bos in
  let slots =
    if OS.Cmd.exists Cmd.(v "git") |> Utils.rmsg then slots
    else begin
      Winget.install [ "Git.Git" ];
      let git_exe =
        match Sys.getenv_opt "ProgramFiles" with
        | Some pf -> Fpath.(v pf / "Git" / "cmd" / "git.exe")
        | None -> Fpath.v {|C:\Program Files\Git\cmd\git.exe|}
      in
      Slots.add_git slots git_exe
    end
  in
  match global_dkml with
  | None ->
      let cwd = OS.Dir.current () |> Utils.rmsg in
      let target_msys2_dir = Fpath.(cwd / ".tools" / "msys2") in
      let dash_exe = Fpath.(target_msys2_dir / "usr" / "bin" / "dash.exe") in
      if not (OS.File.exists dash_exe |> Utils.rmsg) then begin
        let cache_dir = Fpath.(cwd / ".tools" / "msys2-cache") in
        MSYS2.install ~target_msys2_dir ~cache_dir ()
      end;
      Slots.add_msys2 slots target_msys2_dir
  | Some () -> (
      if None = (find_dkml_win32 () |> Utils.rmsg) then
        Winget.install [ "Diskuv.OCaml" ];
      match find_dkml_win32 () |> Utils.rmsg with
      | Some dkml_exe ->
          OS.Cmd.run Cmd.(v (p dkml_exe) % "init" % "--system") |> Utils.rmsg;
          slots
      | None -> failwith "dkml not found after installation")

(** [run ?global_dkml ()].

    Using the flag [~global_dkml:()] will install the ["Diskuv.OCaml"] winget package. *)
let run ?global_dkml ~slots () =
  Utils.start_step
    (match global_dkml with
    | Some () -> "Installing DkML"
    | None -> "Installing DkML prerequisites");
  if Sys.win32 then run_win32 ?global_dkml ~slots () else slots
