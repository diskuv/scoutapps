val run_echo_server :
  ?max_uptime_secs:int -> uppercase:bool -> port:int -> unit -> unit Lwt.t
(** Run a thread to run an echo server *)

val transform : uppercase:bool -> char Lwt_stream.t -> char Lwt_stream.t
(** Echo the stream, possibly using uppercase *)

val test_function : string -> unit -> unit

val create_all_tables :
  Sqlite3.db ->
  Db_utils.return_code * Db_utils.return_code * Db_utils.return_code

val initialize : string -> Sqlite3.db
val pose_to_string : Match_schedule_table.Table.robot_position -> string

module Db_utils = Db_utils

(* module Fetchable_data : sig
  val get_latest_match : Sqlite3.db -> int option
  val get_matches_for_team : Sqlite3.db -> int -> int list

  val get_whole_schedule :
    Sqlite3.db -> (int * int * int * int * int * int * int) list

  val get_missing_records_from_db :
    Sqlite3.db -> (int * Match_schedule_table.Table.robot_position list) list
end *)




module type Database_actions_type = sig
  
  val get_latest_match : unit -> int option 

  val get_matches_for_team : int -> int list

  val get_whole_schedule :
    unit -> (int * int * int * int * int * int * int) list

  val get_missing_records_from_db :
    unit ->
    (int * Match_schedule_table.Table.robot_position list) list

  val initialize : unit -> unit 
end


val create_object : string -> (module Database_actions_type) 
