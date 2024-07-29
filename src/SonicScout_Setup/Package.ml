let package ({ dksdk_data_home; opts; global_dkml } : Develop.common) notarize =
  let global_dkml = if global_dkml then Some () else None in
  try
    InitialSteps.run ~dksdk_data_home ();
    Qt.run ();
    Sqlite3.run ();
    let slots = Slots.create () in
    let slots = DkML.run ?global_dkml ~slots () in
    let slots = ScoutBackend.run ?global_dkml ~opts ~slots () in
    ScoutBackend.package ~notarize ();
    (* TODO when .package is available: ScoutAndroid.run ~next () *)
    ignore slots
  with Utils.StopProvisioning -> ()

module Cli = struct
  open Cmdliner
  open SSCli

  let common_t = Develop.Cli.common_t

  let notarize_t =
    let doc = "Submit the application to Apple for notarization." in
    Arg.(value & flag & info ~doc [ "notarize" ])

  let cmd =
    let doc = "Package the Sonic Scout apps for release." in
    let man = [ `S Manpage.s_description; `Blocks help_secs ] in
    Cmd.v
      (Cmd.info ~doc ~man "Package")
      Term.(const package $ Develop.Cli.common_t $ notarize_t)
end

let () =
  if Tr1EntryName.module_id = __MODULE_ID__ then begin
    Tr1Logs_Term.TerminalCliOptions.init ();
    StdExit.exit (Cmdliner.Cmd.eval Cli.cmd)
  end
