let clean (_ : Tr1Logs_Term.TerminalCliOptions.t) =
  try
    ScoutBackend.clean ()
  with Utils.StopProvisioning -> ()

module Cli = struct
  open Cmdliner

  let help_secs =
    [
      `S Manpage.s_commands;
      `S Manpage.s_common_options;
      `P "These options are common to all commands.";
      `S "ADVANCED OPTIONS";
      `S Manpage.s_bugs;
      `P
        "Support the project with a GitHub star at \
         https://github.com/diskuv/dkcoder.";
      `P
        "Leave feedback or bug reports at \
         https://github.com/diskuv/dkcoder/issues.";
    ]

  let cmd =
    let doc = "Removes intermediate files for the Sonic Scout apps." in
    let man = [ `S Manpage.s_description; `Blocks help_secs ] in
    Cmd.v
      (Cmd.info ~doc ~man "provision")
      Term.(const clean $ Tr1Logs_Term.TerminalCliOptions.term)
end

let () =
  Tr1Logs_Term.TerminalCliOptions.init ();
  StdExit.exit (Cmdliner.Cmd.eval Cli.cmd)
