module type Database_actions_type = sig
  val get_latest_match : unit -> int option
  val get_matches_for_team : int -> int list

  val get_whole_schedule :
    unit -> (int * int * int * int * int * int * int) list

  val get_missing_records_from_db :
    unit -> (int * Match_schedule_table.Table.robot_position list) list

  val initialize : unit -> unit
end

(* This is the module type that SquirrelScout_Std.ml implements *)
module type Intf = sig
  module type Database_actions_type = Database_actions_type

  val create_object : string -> (module Database_actions_type)
  val test_function : string -> unit -> unit
  val pose_to_string : Match_schedule_table.Table.robot_position -> string

  (** Do not use these functions except in unit tests *)
  module For_testing : sig
    val create_all_tables :
      Sqlite3.db ->
      Db_utils.return_code * Db_utils.return_code * Db_utils.return_code

    val return_code_to_string : Db_utils.return_code -> string
  end
end
