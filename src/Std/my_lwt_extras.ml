(** This file exists to demonstrate .ml source code can be
    in any directory or subdirectory of DkSDKProject_AddPackage(). *)

(** [limit_uptime_or_never_terminate ?max_uptime_secs f] waits for
    [max_uptime_secs] when specified or waits forever when not specified.
    
    If the wait time is specified, after the wait is done the
    [f ()] function is invoked. *)
let limit_uptime_or_never_terminate ?max_uptime_secs f =
  let ( let* ) = Lwt.bind in
  match max_uptime_secs with
  | Some max_secs ->
      let* () =
        Logs_lwt.debug (fun l ->
            l "Waiting for uptime limit of %d seconds" max_secs)
      in
      let* () = Lwt_unix.sleep (Float.of_int max_secs) in
      let* () =
        Logs_lwt.info (fun l -> l "Uptime limit of %d seconds reached" max_secs)
      in
      f ()
  | None -> fst (Lwt.wait ())
