module Types = struct
  type robot_position = Red_1 | Red_2 | Red_3 | Blue_1 | Blue_2 | Blue_3
end

module type Database_actions_type = sig
  val insert_match_json : json_contents:string -> unit -> unit
  val insert_raw_match_test_data : unit -> unit
  val get_latest_match : unit -> int option
  val get_matches_for_team : int -> int list

  val get_whole_schedule :
    unit -> (int * int * int * int * int * int * int) list

  val get_missing_records_from_db :
    unit -> (int * Types.robot_position list) list

  (* for java *)
  val get_team_for_match_and_position :
    int -> Types.robot_position -> int option

  (* for java *)
  val insert_scouted_data : string -> Db_utils.return_code
end

(* This is the module type that SquirrelScout_Std.ml implements *)
module type Intf = sig
  module type Database_actions_type = Database_actions_type
  module Schema = Schema
  module Types = Types

  val create_object : db_path:string -> unit -> (module Database_actions_type)
  val test_function : string -> unit -> unit
  val pose_to_string : Types.robot_position -> string

  (* for java *)
  val generate_qr_code : string -> (string, string) result

  (** Do not use these functions except in unit tests *)
  module For_testing : sig
    val create_all_tables : Sqlite3.db -> Db_utils.return_code
    val return_code_to_string : Db_utils.return_code -> string
  end
end
