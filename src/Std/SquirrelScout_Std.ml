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

(* module Match_schedule_table = Match_schedule_table  *)

let create_all_tables db =
  let code = Raw_match_data_table.Table.create_table db in
  let code1 = Match_schedule_table.Table.create_table db in
  let code2 = Robot_pictures_table.Table.create_table db in

  (code, code1, code2)

module Db_utils = Db_utils

let test_function () =
  let db = Sqlite3.db_open "testing.db" in 
  let _ = create_all_tables db in 
  ()  

  
