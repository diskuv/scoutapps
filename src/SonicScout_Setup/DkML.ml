open Utils

let find_dkml_win32 () =
  let open Bos in
  (* ex. C:\Users\beckf\AppData\Local\Programs\DkMLNative\bin\dkml.exe *)
  let localappdata = Sys.getenv "LOCALAPPDATA" in
  OS.Cmd.find_tool
    ~search:Fpath.[ v localappdata / "Programs" / "DkMLNative" / "bin" ]
    Cmd.(v "dkml")

let run_win32 ?global_dkml () =
  let open Bos in
  if not (OS.File.exists (Fpath.v {|C:\VS\Common7\Tools\VsDevCmd.bat|}) |> rmsg)
  then
    Winget.install
      [
        "Microsoft.VisualStudio.2019.BuildTools";
        "--override";
        {|--wait --passive --installPath C:\VS --addProductLang En-us --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended|};
      ];
  if not (OS.Cmd.exists Cmd.(v "git") |> rmsg) then Winget.install [ "Git.Git" ];
  match global_dkml with
  | None ->
      let cwd = OS.Dir.current () |> rmsg in
      let target_msys2_dir = Fpath.(cwd / ".tools" / "msys2") in
      let dash_exe = Fpath.(target_msys2_dir / "usr" / "bin" / "dash.exe") in
      if not (OS.File.exists dash_exe |> rmsg) then begin
        let cache_dir = Fpath.(cwd / ".tools" / "msys2-cache") in
        MSYS2.install ~target_msys2_dir ~cache_dir ()
      end;
      [ `MSYS2 target_msys2_dir ]
  | Some () -> (
      if None = (find_dkml_win32 () |> rmsg) then
        Winget.install [ "Diskuv.OCaml" ];
      match find_dkml_win32 () |> rmsg with
      | Some dkml_exe ->
          OS.Cmd.run Cmd.(v (p dkml_exe) % "init" % "--system") |> rmsg;
          []
      | None -> failwith "dkml not found after installation")

(** [run ?global_dkml ()].

    Using the flag [~global_dkml:()] will install the ["Diskuv.OCaml"] winget package. *)
let run ?global_dkml () =
  start_step
    (match global_dkml with
    | Some () -> "Installing DkML"
    | None -> "Installing DkML prerequisites");
  if Sys.win32 then run_win32 ?global_dkml () else []
