open Utils

let run_win32 () =
  let open Bos in
  OS.Cmd.run
    Cmd.(
      v "winget" % "install" % "Microsoft.VisualStudio.2019.BuildTools"
      % "--override"
      % {|--wait --passive --installPath C:\VS --addProductLang En-us --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended|})
  |> rmsg;
  OS.Cmd.run Cmd.(v "winget" % "install" % "Git.Git") |> rmsg;
  OS.Cmd.run Cmd.(v "winget" % "install" % "Diskuv.OCaml") |> rmsg;
  OS.Cmd.run Cmd.(v "dkml" % "init" % "--system") |> rmsg

let run () =
  start_step "Installing DkML";
  if Sys.win32 then run_win32 ()
