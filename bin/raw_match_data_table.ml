let table_name = "raw_match_data"

let create_table_sql_cols =
  [|
    "team_number INT";
    "team_name TEXT";
    "match INT";
    "scouter_name TEXT";
    (* auto *)
    "auto_moblity INT";
    "auto_climb TEXT";
    "auto_cone_high INT";
    "auto_cone_mid INT";
    "auto_cone_low INT";
    "auto_cube_high INT";
    "auto_cube_mid INT";
    "auto_cube_low INT";
    (* tele *)
    "tele_climb TEXT";
    "tele_cone_high INT";
    "ele_cone_mid INT";
    "tele_cone_low INT";
    "tele_cube_high INT";
    "tele_cube_mid INT";
    "tele_cube_low INT";
    (* mics *)
    "incap INT";
    "playing_defense INT";
    "notes TEXT";
  |]

type climb = No_climb | Docked | Engaged

let climb_to_string = function
  | No_climb -> "NONE"
  | Docked -> "DOCKED"
  | Engaged -> "Engaged"

type raw_match_data_table_record = {
  (* team *)
  team_number : int;
  team_name : string;
  match_number : int;
  scouter_name : string;
  (* auto *)
  auto_mobility : bool;
  auto_climb : climb;
  auto_cone_high : int;
  auto_cone_mid : int;
  auto_cone_low : int;
  auto_cube_high : int;
  auto_cube_mid : int;
  auto_cube_low : int;
  (* tele *)
  tele_climb : climb;
  tele_cone_high : int;
  tele_cone_mid : int;
  tele_cone_low : int;
  tele_cube_high : int;
  tele_cube_mid : int;
  tele_cube_low : int;
  (* misc *)
  incap : bool;
  playing_defense : bool;
  notes : string;
}

let create_table db =
  let initial_sql = "CREATE TABLE " ^ table_name ^ "(" in

  let rec table_colums_as_string_list i list =
    if i == Array.length create_table_sql_cols then list
    else
      let new_list = List.append list [ create_table_sql_cols.(i) ] in
      table_colums_as_string_list (i + 1) new_list
  in

  let colum_list = table_colums_as_string_list 0 [] in

  let primary_keys = "PRIMARY KEY(team_number,match,scouter_name)" in

  let finilazed_sql =
    initial_sql ^ String.concat "," colum_list ^ "," ^ primary_keys ^ ") STRICT"
  in

  Db_operation_utils.create_table_helper db finilazed_sql table_name

(* upsert *)
(* return primary key option None or primary key *)
let insert_db_record db data =
  let open Sqlite3 in
  let open Db_operation_utils in
  let insert_sql =
    "INSERT INTO " ^ table_name
    ^ " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
  in

  let insert_stmt = prepare db insert_sql in

  (* let bind_in = DB_operation_utils.bind_insert_stmt insert_stmt db  *)
  let bind_insert_stmt =
    Db_operation_utils.bind_insert_statement insert_stmt db
  in

  bind_insert_stmt 1 (Data.INT (Int64.of_int data.team_number));
  bind_insert_stmt 2 (Data.TEXT data.team_name);
  bind_insert_stmt 3 (Data.INT (Int64.of_int data.match_number));
  bind_insert_stmt 4 (Data.TEXT data.scouter_name);

  (* auto *)
  bind_insert_stmt 5 (Data.INT (int64_of_bool data.auto_mobility));
  bind_insert_stmt 6 (Data.TEXT (climb_to_string data.auto_climb));

  bind_insert_stmt 7 (Data.INT (Int64.of_int data.auto_cone_high));
  bind_insert_stmt 8 (Data.INT (Int64.of_int data.auto_cone_mid));
  bind_insert_stmt 9 (Data.INT (Int64.of_int data.auto_cone_low));

  bind_insert_stmt 10 (Data.INT (Int64.of_int data.auto_cube_high));
  bind_insert_stmt 11 (Data.INT (Int64.of_int data.auto_cube_mid));
  bind_insert_stmt 12 (Data.INT (Int64.of_int data.auto_cube_low));

  (* tele *)
  bind_insert_stmt 13 (Data.TEXT (climb_to_string data.tele_climb));

  bind_insert_stmt 14 (Data.INT (Int64.of_int data.tele_cone_high));
  bind_insert_stmt 15 (Data.INT (Int64.of_int data.tele_cone_mid));
  bind_insert_stmt 16 (Data.INT (Int64.of_int data.tele_cone_low));

  bind_insert_stmt 17 (Data.INT (Int64.of_int data.tele_cube_high));
  bind_insert_stmt 18 (Data.INT (Int64.of_int data.tele_cube_mid));
  bind_insert_stmt 19 (Data.INT (Int64.of_int data.tele_cube_low));

  (* misc *)
  bind_insert_stmt 20 (Data.INT (int64_of_bool data.incap));
  bind_insert_stmt 21 (Data.INT (int64_of_bool data.playing_defense));
  bind_insert_stmt 22 (Data.TEXT data.notes);

  match step insert_stmt with
  | Rc.DONE ->
      let row_id = Sqlite3.last_insert_rowid db in
      Printf.printf
        "SUCCESSFULLY INSERTED RECORD INTO: \n\
        \          *TABLE=%S \n\
        \          *row_id=%d\n\
        \          *team_number=%d \n\
        \          *match_number=%d \n\
        \          *scouter_name=%s \n"
        table_name (Int64.to_int row_id) data.team_number data.match_number
        data.scouter_name;

      Some (data.team_number, data.match_number, data.scouter_name)
  | r ->
      Db_operation_utils.formatted_error_message db r
        ("Failed to insert record into " ^ table_name);
      None

(* get data functions *)
