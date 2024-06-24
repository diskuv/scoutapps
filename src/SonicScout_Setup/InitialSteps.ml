open Utils

let ask_gitlab_token () =
  let rec ask () =
    StdIo.print_string
      {|
Enter the DkSDK GitLab token you received at https://diskuv.com/pricing.
First Robotics teams can get one for free by emailing jonah AT diskuv.com.

Enter GitLab token (it starts with 'glpat-'): |};
    StdIo.flush StdIo.stdout;
    try
      match StdIo.input_line StdIo.stdin with
      | answer when String.starts_with ~prefix:"glpat-" answer -> Some answer
      | "" -> None
      | _ -> ask ()
    with End_of_file -> None
  in
  ask ()

let run ~dksdk_data_home () =
  start_step "Configuring access to DkSDK";
  if Bos.OS.Dir.create dksdk_data_home |> rmsg then
    Logs.info (fun l ->
        l "Created directory DKSDK_DATA_HOME=%a" Fpath.pp dksdk_data_home)
  else
    Logs.info (fun l ->
        l "Found directory DKSDK_DATA_HOME=%a" Fpath.pp dksdk_data_home);
  let repository_ini = Fpath.(dksdk_data_home / "repository.ini") in
  if Bos.OS.File.exists repository_ini |> rmsg then begin
    Logs.info (fun l ->
        l "Re-using dksdk-access configuration at %a" Fpath.pp repository_ini)
  end
  else begin
    match ask_gitlab_token () with
    | None -> raise StopProvisioning
    | Some token ->
        Out_channel.with_open_bin (Fpath.to_string repository_ini) (fun oc ->
            Out_channel.output_string oc
              "# https://diskuv.com/cmake/help/latest/guide/subscriber-access/";
            Out_channel.output_char oc '\n';
            Out_channel.output_string oc
              (Printf.sprintf
                 "1_0 = https://oauth2:%s@gitlab.com/diskuv/distributions/1.0"
                 token);
            Out_channel.output_char oc '\n')
  end
