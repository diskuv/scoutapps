let ask_signup () =
  let url =
    "https://buy.stripe.com/28ocPd2u1bVQ4wM5ko?prefilled_promo_code=SONIC24SCOUT"
  in
  let rec ask () =
    Printf.printf
      {|
Before proceeding further you will need a "DkSDK GitLab token".

First Robotics team mentors can sign up as DkSDK subscribers for
free. As a team mentor you will receive a DkSDK GitLab token every
six (6) months that you can share with your team.

Not a team mentor? Please stop, get your team mentor, and then come
back!

In exchange for the free token, your team has a responsibility to
share any SonicScout modifications with the broader First Robotics
community at the end of each robotics season.

Menu
----

1. Receive your team's DkSDK GitLab token by completing the free
   signup at
   %s
   in your web browser. You'll get an email which has the token
   (and many more things which you can ignore for now).
2. Your team already has a DkSDK GitLab token.
3. Exit this program.

Enter 1, 2 or 3: |}
      url;
    StdIo.flush StdIo.stdout;
    let open Utils in
    try
      match StdIo.input_line StdIo.stdin with
      | "1" ->
          DkNet_Std.Browser.open_url ~os:Tr1HostMachine.os (Uri.of_string url)
          |> rmsg
      | "2" -> ()
      | "3" -> raise StopProvisioning
      | _ -> ask ()
    with End_of_file ->
      StdIo.print_endline "<terminal or standard input closed> ... exiting";
      raise StopProvisioning
  in
  ask ()

let ask_gitlab_token () =
  let rec ask () =
    StdIo.print_string
      {|
Enter your team's DkSDK GitLab token (it starts with 'glpat-'): |};
    StdIo.flush StdIo.stdout;
    try
      match StdIo.input_line StdIo.stdin with
      | answer when String.starts_with ~prefix:"glpat-" (String.trim answer) ->
          Some (String.trim answer)
      | "" -> None
      | _ -> ask ()
    with End_of_file -> None
  in
  ask ()

let run ~dksdk_data_home () =
  Utils.start_step "Configuring access to DkSDK";
  if Bos.OS.Dir.create dksdk_data_home |> Utils.rmsg then
    Logs.info (fun l ->
        l "Created directory DKSDK_DATA_HOME=%a" Fpath.pp dksdk_data_home)
  else
    Logs.info (fun l ->
        l "Found directory DKSDK_DATA_HOME=%a" Fpath.pp dksdk_data_home);
  let repository_ini = Fpath.(dksdk_data_home / "repository.ini") in
  if Bos.OS.File.exists repository_ini |> Utils.rmsg then begin
    Logs.info (fun l ->
        l "Re-using dksdk-access configuration at %a" Fpath.pp repository_ini)
  end
  else begin
    ask_signup ();
    match ask_gitlab_token () with
    | None -> raise Utils.StopProvisioning
    | Some token ->
        Out_channel.with_open_bin (Fpath.to_string repository_ini) (fun oc ->
            Out_channel.output_string oc "[base]";
            Out_channel.output_char oc '\n';
            Out_channel.output_string oc
              "# https://diskuv.com/cmake/help/latest/guide/subscriber-access/";
            Out_channel.output_char oc '\n';
            Out_channel.output_string oc
              (Printf.sprintf
                 "1_0 = https://oauth2:%s@gitlab.com/diskuv/distributions/1.0"
                 token);
            Out_channel.output_char oc '\n')
  end

module OnCmdliner (Cmdliner : module type of Cmdliner) = struct
  let configure_t =
    let open SSCli in
    Cmdliner.Term.(
      const (fun _ dksdk_data_home -> run ~dksdk_data_home ())
      $ Tr1Logs_Term.TerminalCliOptions.term ~short_opts:() ()
      $ dksdk_data_home_t)

  let f () =
    let doc = "Configure DkSDK's repository.ini" in
    Cmdliner.Cmd.v (Cmdliner.Cmd.info ~doc __MODULE_ID__) configure_t
end

let __init () =
  if Tr1EntryName.module_id = __MODULE_ID__ then begin
    Tr1Logs_Term.TerminalCliOptions.init ();
    let module V = OnCmdliner (Cmdliner) in
    StdExit.exit (Cmdliner.Cmd.eval (V.f ()))
  end
