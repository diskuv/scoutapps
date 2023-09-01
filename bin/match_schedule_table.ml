let table_name = "match_schudle_table"

type colum_contents = { name : string; data_type : string }

type database_colums =
  | Match_Number
  | Red_1
  | Red_2
  | Red_3
  | Blue_1
  | Blue_2
  | Blue_3

let database_colums_name = function
  | Match_Number -> "match_number"
  | Red_1 -> "red_1"
  | Red_2 -> "red_2"
  | Red_3 -> "red_3"
  | Blue_1 -> "blue_1"
  | Blue_2 -> "blue_2"
  | Blue_3 -> "blue_3"

let database_colums_datatype = function
  | Match_Number -> "INT PRIMARY KEY"
  | Red_1 -> "INT"
  | Red_2 -> "INT"
  | Red_3 -> "INT"
  | Blue_1 -> "INT"
  | Blue_2 -> "INT"
  | Blue_3 -> "INT"

let ordered_database_colums =
  [ Match_Number; Red_1; Red_2; Red_3; Blue_1; Blue_2; Blue_3 ]

type robot_position = Red_1 | Red_2 | Red_3 | Blue_1 | Blue_2 | Blue_3

let robot_position_to_string = function
  | Red_1 -> "red_1"
  | Red_2 -> "red_2"
  | Red_3 -> "red_3"
  | Blue_1 -> "blue_1"
  | Blue_2 -> "blue_2"
  | Blue_3 -> "blue_3"

let create_table db =
  let sql =
    Db_operation_utils.create_table_sql_builder ~table_name
      ~cols:ordered_database_colums ~to_name:database_colums_name
      ~to_datatype:database_colums_datatype
  in

  Db_operation_utils.create_table_helper db sql table_name

let fill_database_from_json db json =
  let safe_yojson = Yojson.Safe.from_string json in

  let basic_yojson = Yojson.Safe.to_basic safe_yojson in

  let records = Yojson.Basic.Util.member "records" basic_yojson in

  let records_list =
    match records with `List t -> t | _ -> failwith "failed"
  in

  let insert_indivisual_record data =
    let open Sqlite3 in
    let sql = "INSERT INTO " ^ table_name ^ " VALUES(?,?,?,?,?,?,?)" in
    let insert_stmt = prepare db sql in

    let bind_insert_stmt =
      Db_operation_utils.bind_insert_statement insert_stmt db
    in

    let get_int_member str yojson =
      match Yojson.Basic.Util.member str yojson with
      | `Int n -> n
      | _ -> failwith "not number"
    in

    let match_number = get_int_member "match_number" data in
    let red_1 = get_int_member "red_1" data in
    let red_2 = get_int_member "red_2" data in
    let red_3 = get_int_member "red_3" data in
    let blue_1 = get_int_member "blue_1" data in
    let blue_2 = get_int_member "blue_2" data in
    let blue_3 = get_int_member "blue_3" data in

    bind_insert_stmt 1 (Data.INT (Int64.of_int match_number));

    bind_insert_stmt 2 (Data.INT (Int64.of_int red_1));
    bind_insert_stmt 3 (Data.INT (Int64.of_int red_2));
    bind_insert_stmt 4 (Data.INT (Int64.of_int red_3));

    bind_insert_stmt 5 (Data.INT (Int64.of_int blue_1));
    bind_insert_stmt 6 (Data.INT (Int64.of_int blue_2));
    bind_insert_stmt 7 (Data.INT (Int64.of_int blue_3));

    match step insert_stmt with
    | Rc.DONE ->
        let row_id = Sqlite3.last_insert_rowid db in
        Printf.printf
          "SUCCESSFULLY INSERTED RECORD INTO: \n\
          \          *TABLE=%S \n\
          \          *row_id=%d\n\
          \          *match_number=%d \n\
          \ " table_name (Int64.to_int row_id) match_number
    | r ->
        Db_operation_utils.formatted_error_message db r
          ("failed to insert record into " ^ table_name)
  in

  List.iter (fun a -> insert_indivisual_record a) records_list

(* getting data functions *)


let get_team_for_match_and_position db match_number position =
  let to_select = robot_position_to_string position in
  let where =
    [(database_colums_name Match_Number, string_of_int match_number) ]
  in

  let result =
    Db_operation_utils.select_int_field_where db ~table_name ~to_select ~where 
  in

  match result with Some (x :: []) -> Some x | _ -> None

(* let get_all_matches_for_team db team =
   let to_select = database_colums_name Match_Number in 

    let team_str = string_of_int team in  *)
