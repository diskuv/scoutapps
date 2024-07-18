let provision (_ : Tr1Logs_Term.TerminalCliOptions.t) dksdk_data_home next
    notarize =
  try
    InitialSteps.run ~dksdk_data_home ();
    Qt.run ();
    Sqlite3.run ();
    DkML.run ();
    ScoutBackend.run ?global_dkml ~next ();
    ScoutBackend.package ?global_dkml ~notarize ();
    ScoutAndroid.run ~next ()
  with Utils.StopProvisioning -> ()

module Cli = struct
  open Cmdliner
  open SSCli

  let notarize_t =
    let doc = "Submit the application to Apple for notarization." in
    Arg.(value & flag & info ~doc [ "notarize" ])

  let cmd =
    let doc = "Package the Sonic Scout apps for release." in
    let man = [ `S Manpage.s_description; `Blocks help_secs ] in
    Cmd.v
      (Cmd.info ~doc ~man "Package")
      Term.(
        const provision $ Tr1Logs_Term.TerminalCliOptions.term
        $ dksdk_data_home_t $ next_t $ notarize_t)
end

let () =
  Tr1Logs_Term.TerminalCliOptions.init ();
  StdExit.exit (Cmdliner.Cmd.eval Cli.cmd)
