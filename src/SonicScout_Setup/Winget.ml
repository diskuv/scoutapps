open Utils

let install_winget () =
  let open Bos in
  Logs.info (fun l -> l "Installing winget");
  OS.Cmd.run
    Cmd.(v (Filename.concat (Tr1Assets.LocalDir.v ()) "install-winget.cmd"))
  |> rmsg

let install args =
  let open Bos in
  (* Install winget if we can't locate it. *)
  let winget_cmd = Cmd.(v "winget") in
  let winget_cmd =
    match OS.Cmd.find_tool winget_cmd |> rmsg with
    | Some winget_exe -> Cmd.(v (p winget_exe))
    | None ->
        install_winget ();
        winget_cmd
  in
  (* Do `winget install xyz` *)
  Logs.info (fun l ->
      l "winget install %a" (Fmt.list ~sep:Fmt.sp Fmt.string) args);
  match OS.Cmd.run_status Cmd.(winget_cmd % "install" %% of_list args) with
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
