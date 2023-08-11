let int64_of_bool = function false -> 0L | true -> 1L

let formatted_error_message db error message =
  prerr_endline
    ("**ERROR** \n *error code: " ^ Sqlite3.Rc.to_string error
   ^ "\n *last db error message: " ^ Sqlite3.errmsg db ^ "\n *debug message: "
   ^ message ^ "\n")

let bind_insert_statement insert_stmt db pos data =
  let open Sqlite3 in
  let result = bind insert_stmt pos data in
  match result with
  | Rc.OK -> ()
  | r ->
      prerr_endline (Rc.to_string r);
      prerr_endline (errmsg db)

let create_table_helper db sql table_name =
  match Sqlite3.exec db sql with
  | Sqlite3.Rc.OK ->
      print_endline ("SUCCESSFULLY CREATED: " ^ table_name ^ " TABLE")
  | _ ->
      print_endline
        ("TABLE " ^ table_name ^ " ALREADY EXISTS-----CONTINUING WITH PROGRAM")

let get_blob_or_text_result_list_for_query db sql =
  let open Sqlite3 in
  let stmt = prepare db sql in

  let vector = Vector.create ~dummy:"" in

  let fill_int_vector_single_colum stmt vector =
    let open Sqlite3 in
    while step stmt = Rc.ROW do
      let num_colums = data_count stmt in
      if num_colums > 1 then (
        print_endline "TOO MANY RESULT COLUMS";
        Vector.clear vector)
      else
        let value = column stmt 0 in

        match Data.to_string value with
        | Some s -> Vector.append vector (Vector.make 1 ~dummy:s)
        | None ->
            print_endline "EXPECTED BLOB FROM DATABASE ";
            Vector.clear vector
    done
  in

  fill_int_vector_single_colum stmt vector;

  match Vector.length vector with
  | 0 -> None
  | _ -> Some (Vector.to_list vector)

let get_int_result_list_for_query db sql =
  let open Sqlite3 in
  let stmt = prepare db sql in

  let vector = Vector.create ~dummy:0 in

  let fill_int_vector_single_colum stmt vector =
    let open Sqlite3 in
    while step stmt = Rc.ROW do
      let num_colums = data_count stmt in
      if num_colums > 1 then (
        print_endline "TOO MANY RESULT COLUMS";
        Vector.clear vector)
      else
        let value = column stmt 0 in

        match Data.to_int value with
        | Some x -> Vector.append vector (Vector.make 1 ~dummy:x)
        | None ->
            print_endline "EXPECTED INT FROM DATABASE ";
            Vector.clear vector
    done
  in

  fill_int_vector_single_colum stmt vector;

  match Vector.length vector with
  | 0 -> None
  | _ -> Some (Vector.to_list vector)

let db_int num =
  let int64 = Int64.of_int num in
  Sqlite3.Data.INT int64

let db_text str = Sqlite3.Data.TEXT str

let db_bool bol =
  let num = int64_of_bool bol in
  Sqlite3.Data.INT num
