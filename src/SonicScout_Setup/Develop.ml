let provision (_ : Tr1Logs_Term.TerminalCliOptions.t) dksdk_data_home next
    global_dkml =
  try
    InitialSteps.run ~dksdk_data_home ();
    Qt.run ();
    Sqlite3.run ();
    let properties = DkML.run ?global_dkml () in
    ScoutBackend.run ?next ?global_dkml ~properties ();
    ScoutAndroid.run ?next ();
    AndroidStudio.run ();
    Utils.done_steps "Developing"
  with Utils.StopProvisioning -> ()

module Cli = struct
  open Cmdliner
  open SSCli

  let cmd =
    let doc =
      "Develop the Sonic Scout apps. Your machine will be setup with \
       prerequisites, and code will be compiled, if it hasn't been already."
    in
    let man = [ `S Manpage.s_description; `Blocks help_secs ] in
    Cmd.v
      (Cmd.info ~doc ~man "Develop")
      Term.(
        const provision $ Tr1Logs_Term.TerminalCliOptions.term
        $ dksdk_data_home_t $ next_t $ global_dkml_t)
end

let () =
  Tr1Logs_Term.TerminalCliOptions.init ();
  StdExit.exit (Cmdliner.Cmd.eval Cli.cmd)
