type climb = No_climb | Docked | Engaged
val climb_to_string : climb -> string
type db_record = {
  team_number : int64;
  team_name : string;
  match_number : int64;
  auto_mobility : bool;
  auto_climb : climb;
  auto_cone_high : int64;
  auto_cone_mid : int64;
  auto_cone_low : int64;
  auto_cube_high : int64;
  auto_cube_mid : int64;
  auto_cube_low : int64;
  tele_climb : climb;
  tele_cone_high : int64;
  tele_cone_mid : int64;
  tele_cone_low : int64;
  tele_cube_high : int64;
  tele_cube_mid : int64;
  tele_cube_low : int64;
  incap : bool;
  playing_defense : bool;
  notes : string;
}
val table_colums_arr : string array
val table_name : string
val get_create_table_sql : string array -> string
val int64_of_bool : bool -> int64
val formatted_error_message : Sqlite3.Rc.t -> string -> unit
val insert_db_record : db_record -> unit
val sample_data : db_record
val sql : string
val print_to_console_cb : string option array -> string array -> unit
val get_whole_table : (Sqlite3.row -> Sqlite3.headers -> unit) -> unit
val execute_select_sql :
  (Sqlite3.row -> Sqlite3.headers -> unit) -> string -> unit
val create_table : unit
