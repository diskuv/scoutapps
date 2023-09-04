val run_echo_server :
  ?max_uptime_secs:int -> uppercase:bool -> port:int -> unit -> unit Lwt.t
(** Run a thread to run an echo server *)

val transform : uppercase:bool -> char Lwt_stream.t -> char Lwt_stream.t
(** Echo the stream, possibly using uppercase *)

val test_function : unit -> unit

val create_all_tables :
  Sqlite3.db ->
  Db_utils.return_code * Db_utils.return_code * Db_utils.return_code

module Db_utils = Db_utils
