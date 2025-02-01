(* This script is standalone. *)
let rmsg = function Ok v -> v | Error (`Msg msg) -> failwith msg

(** Search standard places for Visual Studio. *)
let find_vsdir () =
  let open Bos in
  let is_vsdir candidate =
    (* Common7\Tools\Microsoft.VisualStudio.DevShell.dll needed for RunCMake *)
    OS.File.exists
      Fpath.(
        candidate / "Common7" / "Tools" / "Microsoft.VisualStudio.DevShell.dll")
    |> rmsg
  in
  let search =
    (* Eventually we should download vswhere.exe and use it. Also 2022 should work. *)
    List.map Fpath.v
      [
        {|C:\VS|};
        {|C:\Program Files (x86)\Microsoft Visual Studio\2019\Community|};
        {|C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional|};
        {|C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise|};
      ]
  in
  List.find_opt is_vsdir search

let run ?global_dkml ~slots () =
  Utils.start_step "Installing Visual Studio";
  let open Bos in
  let vsdir_opt =
    match global_dkml with
    | None ->
        (* Search standard places for Visual Studio *)
        find_vsdir ()
    | Some () -> (
        (* If we have DkML installed try to use its Visual Studio installation. *)
        let vsdirtxt =
          Fpath.(
            v (Sys.getenv "LOCALAPPDATA")
            / "Programs" / "DkML" / "vsstudio.dir.txt")
        in
        match OS.File.read vsdirtxt with
        | Ok contents -> Some (Fpath.v (String.trim contents))
        | Error _ ->
            (* If we can't find it, do a standard search *)
            find_vsdir ())
  in
  match vsdir_opt with
  | Some vsdir -> Slots.add_vsdir slots vsdir
  | None ->
      Winget.install
        [
          "Microsoft.VisualStudio.2019.BuildTools";
          "--override";
          {|--wait --passive --installPath C:\VS --addProductLang En-us --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended|};
        ];
      Slots.add_vsdir slots (Fpath.v {|C:\VS|})
