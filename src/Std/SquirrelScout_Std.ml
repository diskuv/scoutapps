(** Adapted from: https://github.com/dkim/rwo-lwt *)

let ( let* ) = Lwt.bind

let pp_sockaddr fmt = function
  | Unix.ADDR_UNIX name -> Fmt.pf fmt "ADDR_UNIX (name=%s)" name
  | Unix.ADDR_INET (addr, port) ->
      Fmt.pf fmt "ADDR_INET (addr=%s, port=%d)"
        (Unix.string_of_inet_addr addr)
        port

let transform = Uppercase.transform

let run_echo_server ?max_uptime_secs ~uppercase ~port () =
  let* server =
    let* () =
      Logs_lwt.info (fun l ->
          l "Listening on port %d with uppercase %b" port uppercase)
    in
    Lwt_io.establish_server_with_client_address
      (Lwt_unix.ADDR_INET (Unix.inet_addr_any, port))
      (fun (client : Unix.sockaddr) (r, w) ->
        let* () =
          Logs_lwt.info (fun l ->
              l "Connected to client at %a" pp_sockaddr client)
        in
        Lwt_io.read_chars r |> transform ~uppercase |> Lwt_io.write_chars w)
  in
  My_lwt_extras.limit_uptime_or_never_terminate ?max_uptime_secs (fun () ->
      Lwt_io.shutdown_server server)
