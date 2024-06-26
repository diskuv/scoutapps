open Utils

let install args =
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
