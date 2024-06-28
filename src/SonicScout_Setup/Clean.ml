let clean (_ : Tr1Logs_Term.TerminalCliOptions.t) areas =
  try ScoutBackend.clean areas with Utils.StopProvisioning -> ()

module Cli = struct
  open Cmdliner

  let s_areas = "AREAS"

  let help_secs =
    [
      `P "By default nothing is cleaned unless an area is selected.";
      `P
        "Areas are additive; more than one means all selected areas are \
         cleaned.";
      `S s_areas;
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

  let areas_t =
    let infos =
      Arg.
        [
          ( [ `DkSdkSourceCode ],
            info ~docs:s_areas
              ~doc:"Clean the DkSDK source code in fetch/ folders."
              [ "dksdk-source-code" ] );
          ( [ `Builds ],
            info ~docs:s_areas ~doc:"Clean the build artifacts." [ "builds" ] );
          ( [ `Builds; `DkSdkSourceCode ],
            info ~docs:s_areas ~doc:"Cleans everything." [ "all" ] );
        ]
    in
    let t = Arg.(value & vflag_all [] infos) in
    let t = Term.(const List.concat $ t) in
    Term.(const (List.sort_uniq compare) $ t)

  let cmd =
    let doc = "Removes intermediate files for the Sonic Scout apps." in
    let man = [ `S Manpage.s_description; `Blocks help_secs ] in
    Cmd.v
      (Cmd.info ~doc ~man "Clean")
      Term.(const clean $ Tr1Logs_Term.TerminalCliOptions.term $ areas_t)
end

let () =
  Tr1Logs_Term.TerminalCliOptions.init ();
  StdExit.exit (Cmdliner.Cmd.eval Cli.cmd)
