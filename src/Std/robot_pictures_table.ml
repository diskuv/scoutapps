(* module Table : Db_utils.Generic_Table = struct

   end *)

module Table : Db_utils.Generic_Table = struct
  let table_name = "robot_pictures_table"

  type colums = Team_number | Image

  let colum_name = function Team_number -> "team_number" | Image -> "image"
  let colum_datatype = function Team_number -> "INT" | Image -> "BLOB"
  let colums_in_order = [ Team_number; Image ]
  let primary_keys = [ Team_number ]

  let create_table db =
    Db_utils.create_table2 db ~table_name ~colums:colums_in_order ~primary_keys
      ~to_name:colum_name ~to_datatype:colum_datatype

  (* FIXME: need to figure out how images will be passed to ocaml. File location? bytedata?  *)
  let drop_table () = Db_utils.Failed
  let insert_record (db : Sqlite3.db) (str : string) = Db_utils.Successful
end

(* let table_name = "robot_pictures_table" *)

(* type robot_picture_record = { team_number : int; image : string } *)

(* let insert_robot_picture_record db record =
     let open Sqlite3 in
     let sql = "INSERT INTO " ^ table_name ^ " VALUES(?,?)" in
     let insert_stmt = prepare db sql in

     let bind_insert_stmt = Db_utils.bind_insert_statement insert_stmt db in

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
         Db_utils.formatted_error_message db r
           ("failed to insert record into " ^ table_name);
         None

   let get_robot_picture db team_number =
     let sql =
       Printf.sprintf "SELECT image FROM %s WHERE team_number=%d" table_name
         team_number
     in

     let result = Db_utils.get_blob_or_text_result_list_for_query db sql in

     match result with Some (t :: []) -> Some t | _ -> None *)
