let table_name = "robot_pictures_table"

type robot_picture_record = { team_number : int; image : string }

let create_table db =
  let sql =
    "CREATE TABLE " ^ table_name ^ "(team_number INT PRIMARY KEY, image BLOB)"
  in

  Db_operation_utils.create_table_helper db sql table_name

let insert_robot_picture_record db record =
  let open Sqlite3 in
  let sql = "INSERT INTO " ^ table_name ^ " VALUES(?,?)" in
  let insert_stmt = prepare db sql in

  let bind_insert_stmt =
    Db_operation_utils.bind_insert_statement insert_stmt db
  in

  bind_insert_stmt 1 (Data.INT (Int64.of_int record.team_number));
  bind_insert_stmt 2 (Data.BLOB record.image);

  match step insert_stmt with
  | Rc.DONE ->
      let row_id = Sqlite3.last_insert_rowid db in
      Printf.printf
        "SUCCESSFULLY INSERTED RECORD INTO: \n\
        \          *TABLE=%S \n\
        \          *row_id=%d\n\
        \          *team_number=%d \n\
        \ " table_name (Int64.to_int row_id) record.team_number;

      Some record.team_number
  | r ->
      Db_operation_utils.formatted_error_message db r
        ("failed to insert record into " ^ table_name);
      None

let get_robot_picture db team_number =
  let sql =
    Printf.sprintf "SELECT image FROM %s WHERE team_number=%d" table_name
      team_number
  in

  let result =
    Db_operation_utils.get_blob_or_text_result_list_for_query db sql
  in

  match result with Some (t :: []) -> Some t | _ -> None
