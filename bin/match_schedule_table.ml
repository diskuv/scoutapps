let table_name = "match_schudle_table"

type robot_position = Red_1 | Red_2 | Red_3 | Blue_1 | Blue_2 | Blue_3

let robot_position_to_string = function
  | Red_1 -> "red_1"
  | Red_2 -> "red_2"
  | Red_3 -> "red_3"
  | Blue_1 -> "blue_1"
  | Blue_2 -> "blue_2"
  | Blue_3 -> "blue_3"

type match_schudle_record = {
  match_number : int;
  red_1 : int;
  red_2 : int;
  red_3 : int;
  blue_1 : int;
  blue_2 : int;
  blue_3 : int;
}
[@@deriving yojson]

type json_input_data = { records : match_schudle_record list }
[@@deriving yojson]

let create_table db =
  let sql =
    "CREATE TABLE " ^ table_name
    ^ "(match_number INT PRIMARY KEY, red_1 INT, red_2 INT, red_3 INT, blue_1 \
       INT, blue_2 INT, blue_3 INT)"
  in

  Db_operation_utils.create_table_helper db sql table_name

let insert_match_schudle_record db match_schudle_record =
  let open Sqlite3 in
  let sql = "INSERT INTO " ^ table_name ^ " VALUES(?,?,?,?,?,?,?)" in
  let insert_stmt = prepare db sql in

  let bind_insert_stmt =
    Db_operation_utils.bind_insert_statement insert_stmt db
  in

  bind_insert_stmt 1 (Data.INT (Int64.of_int match_schudle_record.match_number));

  bind_insert_stmt 2 (Data.INT (Int64.of_int match_schudle_record.red_1));
  bind_insert_stmt 3 (Data.INT (Int64.of_int match_schudle_record.red_2));
  bind_insert_stmt 4 (Data.INT (Int64.of_int match_schudle_record.red_3));

  bind_insert_stmt 5 (Data.INT (Int64.of_int match_schudle_record.blue_1));
  bind_insert_stmt 6 (Data.INT (Int64.of_int match_schudle_record.blue_2));
  bind_insert_stmt 7 (Data.INT (Int64.of_int match_schudle_record.blue_3));

  match step insert_stmt with
  | Rc.DONE ->
      let row_id = Sqlite3.last_insert_rowid db in
      Printf.printf
        "SUCCESSFULLY INSERTED RECORD INTO: \n\
        \          *TABLE=%S \n\
        \          *row_id=%d\n\
        \          *match_number=%d \n\
        \ " table_name (Int64.to_int row_id) match_schudle_record.match_number;

      Some match_schudle_record.match_number
  | r ->
      Db_operation_utils.formatted_error_message db r
        ("failed to insert record into " ^ table_name);
      None

(* getting data functions *)
let get_team_for_match_and_position db match_number position =
  let open Db_operation_utils in
  let sql =
    Printf.sprintf "SELECT %s FROM %s WHERE match_number=%d"
      (robot_position_to_string position)
      table_name match_number
  in

  let result = get_int_result_list_for_query db sql in

  match result with Some (t :: []) -> Some t | _ -> None

let load_database_from_json db data =
  let native_record =
    json_input_data_of_yojson (Yojson.Safe.from_string data)
  in

  let records =
    match native_record with
    | Result.Ok s -> s
    | Result.Error r -> failwith ("failed: " ^ r)
  in

  List.iter
    (fun a ->
      match insert_match_schudle_record db a with
      | Some _ -> print_endline "yes"
      | None -> print_endline "no")
    records.records
