open Utils

let winget_install args =
  let open Bos in
  Logs.info (fun l ->
      l "winget install %a" (Fmt.list ~sep:Fmt.sp Fmt.string) args);
  match OS.Cmd.run_status Cmd.(v "winget" % "install" %% of_list args) with
  | Ok (`Exited 0) -> ()
  | Ok (`Exited -1978335189) ->
      (*Found an existing package already installed.*) ()
  | Ok (`Signaled _ as status) ->
      Logs.err (fun l -> l "Failed to install. %a" OS.Cmd.pp_status status);
      raise StopProvisioning
  | Ok (`Exited _ as status) ->
      Logs.err (fun l -> l "Failed to install. %a" OS.Cmd.pp_status status);
      raise StopProvisioning
  | Error err -> rmsg (Error err)

let run_win32 () =
  let open Bos in
  if not (OS.File.exists (Fpath.v {|C:\VS\Common7\Tools\VsDevCmd.bat|}) |> rmsg)
  then
    winget_install
      [
        "Microsoft.VisualStudio.2019.BuildTools";
        "--override";
        {|--wait --passive --installPath C:\VS --addProductLang En-us --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended|};
      ];
  if not (OS.Cmd.exists Cmd.(v "git") |> rmsg) then winget_install [ "Git.Git" ];
  if not (OS.Cmd.exists Cmd.(v "dkml") |> rmsg) then
    winget_install [ "Diskuv.OCaml" ];
  OS.Cmd.run Cmd.(v "dkml" % "init" % "--system") |> rmsg

let run () =
  start_step "Installing DkML";
  if Sys.win32 then run_win32 ()
