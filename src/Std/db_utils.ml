type return_code = Successful | Failed

let return_code_to_string = function
  | Successful -> "Successful"
  | Failed -> "failed"

module type Generic_Table = sig
  val table_name : string

  type colums

  val colum_name : colums -> string
  val colum_datatype : colums -> string
  val primary_keys : colums list
  val colums_in_order : colums list
  val create_table : Sqlite3.db -> return_code
  val drop_table : unit -> return_code
  val insert_record : Sqlite3.db -> string -> return_code
end

(* -------------- *)

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

let select_int_field_where ?(or_conditional = false) db ~table_name ~to_select
    ~where =
  let _ = db in

  let where_complete_lst : string list =
    let rec build_lst (old_lst : (string * string) list) (new_lst : string list)
        pos =
      if pos == List.length old_lst then new_lst
      else
        let value = List.nth old_lst pos in

        match value with
        | a, b ->
            let combined = a ^ "=" ^ b in
            build_lst old_lst (combined :: new_lst) (pos + 1)
    in

    build_lst where [] 0
  in

  let where_string =
    match or_conditional with
    | true -> String.concat " OR " where_complete_lst
    | _ -> String.concat " AND " where_complete_lst
  in

  let sql =
    match where_string with
    | "" -> Printf.sprintf "SELECT %s FROM %s" to_select table_name
    | _ ->
        Printf.sprintf "SELECT %s FROM %s WHERE %s" to_select table_name
          where_string
  in

  get_int_result_list_for_query db sql

let create_table db table_name lst =
  let rec create_string lst pos str =
    if List.length lst == pos then str
    else
      let name, datatype = List.nth lst pos in

      let new_string = str ^ ", " ^ name ^ " " ^ datatype in

      create_string lst (pos + 1) new_string
  in

  let first_name, first_datatype = List.nth lst 0 in

  let col_string = create_string lst 1 (first_name ^ " " ^ first_datatype) in

  let sql =
    "CREATE TABLE IF NOT EXISTS " ^ table_name ^ "(" ^ col_string ^ ")"
  in

  (* print_endline ("test create table sql: " ^ sql); *)
  match Sqlite3.exec db sql with Sqlite3.Rc.OK -> Successful | _ -> Failed

let create_table2 db ~table_name ~colums ~primary_keys ~to_name ~to_datatype =
  let rec create_string lst pos str =
    if List.length lst == pos then str
    else
      let current_colum = List.nth lst pos in
      let name = to_name current_colum in
      let datatype = to_datatype current_colum in

      let new_string = str ^ ", " ^ name ^ " " ^ datatype in

      create_string lst (pos + 1) new_string
  in

  let first_colum = List.nth colums 0 in
  let initial_string = to_name first_colum ^ " " ^ to_datatype first_colum in

  let all_colums_string = create_string colums 1 initial_string in

  let primary_keys_string =
    let rec build_primary_key_string lst pos str =
      if List.length lst == pos then str
      else
        let current_key = List.nth lst pos in
        let as_string = to_name current_key in

        let new_string = str ^ ", " ^ as_string in

        build_primary_key_string lst (pos + 1) new_string
    in

    let first_key = to_name (List.nth primary_keys 0) in

    let key_names = build_primary_key_string primary_keys 1 first_key in

    ", PRIMARY KEY(" ^ key_names ^ ")"
  in

  let sql =
    "CREATE TABLE IF NOT EXISTS " ^ table_name ^ "(" ^ all_colums_string
    ^ primary_keys_string ^ ")"
  in

  print_endline ("test create table sql: " ^ sql);
  match Sqlite3.exec db sql with Sqlite3.Rc.OK -> Successful | _ -> Failed
