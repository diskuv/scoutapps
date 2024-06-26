open Utils

let run_win32 () =
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
  if not (OS.Cmd.exists Cmd.(v "dkml") |> rmsg) then
    Winget.install [ "Diskuv.OCaml" ];
  OS.Cmd.run Cmd.(v "dkml" % "init" % "--system") |> rmsg

let run () =
  start_step "Installing DkML";
  if Sys.win32 then run_win32 ()
