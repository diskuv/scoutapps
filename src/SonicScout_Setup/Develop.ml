type common = {
  dksdk_data_home : Fpath.t;
  opts : Utils.opts;
  global_dkml : bool;
}

let _compile_backend ~slots { opts; global_dkml; _ } =
  let global_dkml = if global_dkml then Some () else None in
  let slots = Python.run ~slots () in
  Qt.run ~slots ();
  Sqlite3.run ();
  ScoutBackend.run ?global_dkml ~opts ~slots ()

let _compile_base ?skip_android ({ dksdk_data_home; opts; global_dkml } as common) =
  let global_dkml = if global_dkml then Some () else None in

  InitialSteps.run ~dksdk_data_home ();
  let slots = Slots.create () in
  let slots = DkML.run ?global_dkml ~slots () in
  let slots = _compile_backend ~slots common in
  let slots =
    match skip_android with
    | Some () -> slots
    | None -> ScoutAndroid.run ~opts ~slots ()
  in
  slots

let compile common =
  try
    let slots = _compile_base common in
    ignore slots;
    Utils.done_steps "Developing"
  with Utils.StopProvisioning -> ()

let compile_backend common =
  try
    let slots = Slots.create () in
    let slots = _compile_backend ~slots common in
    ignore slots;
    Utils.done_steps "Developing backend"
  with Utils.StopProvisioning -> ()

let launch_android common =
  try
    let slots = _compile_base common in
    let slots = AndroidStudio.run ~slots () in
    ignore slots;
    Utils.done_steps "Developing"
  with Utils.StopProvisioning -> ()

let launch_scanner common =
  try
    let slots = _compile_base ~skip_android:() common in
    let slots = Scanner.run ~slots () in
    ignore slots;
    Utils.done_steps "Developing"
  with Utils.StopProvisioning -> ()

let launch_database common =
  try
    let slots = _compile_base ~skip_android:() common in
    let slots = Database.run ~slots () in
    ignore slots;
    Utils.done_steps "Developing"
  with Utils.StopProvisioning -> ()

module Cli = struct
  open Cmdliner

  let common_t =
    let open SSCli in
    Term.(
      const (fun _ dksdk_data_home opts global_dkml ->
          {
            dksdk_data_home;
            opts;
            global_dkml =
              (match global_dkml with Some () -> true | None -> false);
          })
      $ Tr1Logs_Term.TerminalCliOptions.term ~short_opts:() ()
      $ dksdk_data_home_t $ opts_t $ global_dkml_t)

  let compile_cmd =
    let open SSCli in
    let doc =
      "Compile all Sonic Scout code. Your machine will be setup with \
       prerequisites if it hasn't been already."
    in
    let man = [ `S Manpage.s_description; `Blocks help_secs ] in
    Cmd.v (Cmd.info ~doc ~man "compile") Term.(const compile $ common_t)

  let compile_backend_cmd =
    let open SSCli in
    let doc =
      "Compile all Sonic Scout backend code. Your machine needs to have been setup with \
        prerequisites; you can do that with the './dk SonicScout_Setup.Develop compile' command."
    in
    let man = [ `S Manpage.s_description; `Blocks help_secs ] in
    Cmd.v (Cmd.info ~doc ~man "compile-backend") Term.(const compile_backend $ common_t)
  
  let android_cmd =
    let open SSCli in
    let doc =
      "Launch Android Studio and open the Sonic Scout Android application. \
       Your machine will be setup with prerequisites, and code will be \
       compiled (everything except the Android application itself), if it \
       hasn't been already. Use Android Studio to build and run the Android \
       application on a device emulator or your Android phone / tablet."
    in
    let man = [ `S Manpage.s_description; `Blocks help_secs ] in
    Cmd.v (Cmd.info ~doc ~man "android") Term.(const launch_android $ common_t)

  let scanner_cmd =
    let open SSCli in
    let doc =
      "Launch the QR code scanner. Your machine will be setup with \
       prerequisites, and code will be compiled (everything except Android), \
       if it hasn't been already."
    in
    let man = [ `S Manpage.s_description; `Blocks help_secs ] in
    Cmd.v (Cmd.info ~doc ~man "scanner") Term.(const launch_scanner $ common_t)

  let database_cmd =
    let open SSCli in
    let doc =
      "Launch a shell to read the `sqlite3` database of QR code scans and \
       export CSV files for Excel. Your machine will be setup with \
       prerequisites, and code will be compiled (everything except Android), \
       if it hasn't been already."
    in
    let man = [ `S Manpage.s_description; `Blocks help_secs ] in
    Cmd.v
      (Cmd.info ~doc ~man "database")
      Term.(const launch_database $ common_t)

  let groups_cmd =
    let doc = "Develop the Sonic Scout software." in
    let man = [ `S Manpage.s_description; `Blocks SSCli.help_secs ] in
    let default =
      Term.(ret (const (fun _ -> `Help (`Pager, None)) $ common_t))
    in
    Cmd.group ~default
      (Cmd.info ~doc ~man ("./dk " ^ __MODULE_ID__))
      [ compile_cmd; compile_backend_cmd; android_cmd; scanner_cmd; database_cmd ]
end

let () =
  if Tr1EntryName.module_id = __MODULE_ID__ then begin
    Tr1Logs_Term.TerminalCliOptions.init ();
    StdExit.exit (Cmdliner.Cmd.eval Cli.groups_cmd)
  end
