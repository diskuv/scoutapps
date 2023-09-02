let do_setup_log style_renderer level =
  Fmt_tty.setup_std_outputs ?style_renderer ();
  Logs.set_level level;
  Logs.set_reporter (Logs_fmt.reporter ())

let setup_log_t =
  Cmdliner.Term.(
    const do_setup_log $ Fmt_cli.style_renderer () $ Logs_cli.level ())

let uppercase_t =
  let doc = "Uppercase each character of the request in the echoed response" in
  Cmdliner.Arg.(value & flag & info ~doc [ "u"; "uppercase" ])

let port_t =
  let doc = "The port number to listen for echo requests" in
  Cmdliner.Arg.(value & opt int 8010 & info ~doc [ "p"; "port" ])

let max_uptime_secs_opt_t =
  let doc =
    "If specified, limits the uptime of the echo server to $(docv) number of \
     seconds"
  in
  Cmdliner.Arg.(
    value & opt (some int) None & info ~doc ~docv:"SECS" [ "max-uptime-secs" ])

let main_thread ?max_uptime_secs ~uppercase ~port () =
  (* Don't kill process simply because a socket was closed (SIGPIPE) *)
  (try Sys.set_signal Sys.sigpipe Sys.Signal_ignore
   with Invalid_argument _ ->
     Logs.debug (fun l -> l "SIGPIPE unavailable on this operating system"));
  (* Use libev for speedy alternative to Unix select() loops *)
  if not Sys.win32 then (
    try Lwt_engine.set (new Lwt_engine.libev ())
    with Lwt_sys.Not_available _ as e ->
      Logs.err (fun l ->
          l "libev is unavailable, yet is required on non-Windows platforms");
      raise e);
  (* Run the main thread and wait for it to finish *)
  Lwt_main.run
    (SquirrelScout_Std.run_echo_server ?max_uptime_secs ~uppercase ~port ())

let run_main_thread uppercase port max_uptime_secs () =
  main_thread ?max_uptime_secs ~uppercase ~port ()

let main () =
  let open Cmdliner in
  match
    Cmd.(
      eval
        (v (info "SquirrelScout")
           Term.(
             const run_main_thread $ uppercase_t $ port_t
             $ max_uptime_secs_opt_t $ setup_log_t)))
  with
  | 0 -> exit (if Logs.err_count () > 0 then 2 else 0)
  | ec -> exit ec

let () = 
  (* SquirrelScout_Std.test_function () *)
main ()
