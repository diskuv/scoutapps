let clean (_ : Tr1Logs_Term.TerminalCliOptions.t) areas =
  try
    if List.mem `DkCoderWork areas then begin
      match (Sys.win32, Sys.getenv_opt "LOCALAPPDATA") with
      | true, Some localappdata when localappdata <> "" ->
          (* From [dk.cmd]. We don't support [dk] since not the main SonicScout
             platform and the logic for its [tools_dir] is complex.
             [./dk dksdk.project.get] is legacy and will be replaced anyway. *)
          let dkshare = Fpath.(v localappdata / "Programs" / "DkCoder") in
          let work = Fpath.(dkshare / "work") in
          Utils.start_step "Cleaning DkCoder work directories";
          DkFs_C99.Path.rm ~recurse:() ~force:() ~kill:()
            Fpath.
              [
                (* Avoid:
                    ./dk dksdk.project.get
                    -- Fetching dependencies into Y:/source/scoutapps/us/SonicScoutAndroid/fetch ...
                    CMake Error at C:/Users/beckf/AppData/Local/Programs/DkCoder/work/dksdk___project___get/dksdk-access-subbuild/dksdk-access-populate-prefix/tmp/dksdk-access-populate-gitupdate.cmake:203 (message):
                    Failed to rebase in:
                    'C:/Users/beckf/AppData/Local/Programs/DkCoder/work/dksdk___project___get/dksdk-access-src'.
                    Output from the attempted rebase follows:
                    fatal: It seems that there is already a rebase-merge directory, and
                    I wonder if you are in the middle of another rebase. *)
                work / "dksdk___project___get";
              ]
          |> Utils.rmsg
      | _ -> ()
    end;
    ScoutBackend.clean areas;
    ScoutAndroid.clean areas;
    Utils.done_steps "Cleaning"
  with Utils.StopProvisioning -> ()

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
              ~doc:
                "Clean the DkSDK source code in fetch/ folders, which will \
                 resynchronize all the source code from their upstreams on the \
                 next SonicScout_Setup.Develop command."
              [ "dksdk-source-code" ] );
          ( [ `DkSdkCMake ],
            info ~docs:s_areas
              ~doc:
                "Remove the `dksdk-cmake` source code in fetch/ folders, which \
                 will resynchronize dksdk-cmake from its upstream on the next \
                 SonicScout_Setup.Develop command."
              [ "dksdk-cmake" ] );
          ( [ `AndroidBuilds ],
            info ~docs:s_areas ~doc:"Clean the Android build artifacts." [ "android-builds" ] );
          ( [ `BackendBuilds ],
            info ~docs:s_areas ~doc:"Clean the Backend build artifacts." [ "backend-builds" ] );
          ( [ `AndroidBuilds; `BackendBuilds ],
            info ~docs:s_areas ~doc:"Clean the build artifacts." [ "builds" ] );
          ( [ `DkCoderWork ],
            info ~docs:s_areas ~doc:"Clean the DkCoder work directories."
              [ "dkcoder-work" ] );
          ( [ `QtInstallation ],
            info ~docs:s_areas ~doc:"Clean the Qt installation."
              [ "qt-installation" ] );
          ( [ `MavenRepository ],
            info ~docs:s_areas
              ~doc:"Clean the DkSDK portions of the Maven repository."
              [ "maven-repo" ] );
          ( [
              `AndroidBuilds;
              `BackendBuilds;
              `DkSdkSourceCode;
              `DkCoderWork;
              `QtInstallation;
              `MavenRepository;
            ],
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
      Term.(
        const clean
        $ Tr1Logs_Term.TerminalCliOptions.term ~short_opts:() ()
        $ areas_t)
end

let () =
  Tr1Logs_Term.TerminalCliOptions.init ();
  StdExit.exit (Cmdliner.Cmd.eval Cli.cmd)
