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
  val drop_table : Sqlite3.db -> return_code
  val insert_record : Sqlite3.db -> string -> return_code
end

(* -------------- *)

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

let create_table db ~table_name ~colums ~primary_keys ~to_name ~to_datatype =
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

  (* print_endline ("test create table sql: " ^ sql); *)
  match Sqlite3.exec db sql with Sqlite3.Rc.OK -> Successful | _ -> Failed

module List_Utils = struct
  let sum list =
    let rec calculate lst sum =
      match lst with [] -> sum | h :: t -> calculate t (sum + h)
    in

    calculate list 0

  let average_value list =
    match list with
    | [] -> None
    | l ->
        let length = List.length l in
        let sum = sum l in

        Some (float_of_int sum /. float_of_int length)
end

(* -------- *)

module Select = struct
  type string_or_int = String of string | Int of int
  type order_by = ASC | DESC

  let order_by_to_string = function ASC -> "ASC" | DESC -> "DESC"

  let get_data_helper ?(or_conditional = false) ?(order_by = []) db ~table_name
      ~to_select ~where =
    let where_sql =
      if List.length where == 0 then ""
      else
        let where_as_string_list =
          let rec build_lst old_lst new_lst =
            match old_lst with
            | [] -> new_lst
            | (name, data) :: t ->
                let combined =
                  match data with
                  | String x -> name ^ "=" ^ "\"" ^ x ^ "\""
                  | Int x -> name ^ "=" ^ string_of_int x
                in

                build_lst t (combined :: new_lst)
          in

          build_lst where []
        in

        let filters =
          match or_conditional with
          | true -> String.concat " OR " where_as_string_list
          | false -> String.concat " AND " where_as_string_list
        in

        " WHERE " ^ filters
    in

    let order_sql =
      if List.length order_by == 0 then ""
      else
        let as_string_list =
          let rec build lst new_list =
            match lst with
            | [] -> new_list
            | (data, ordertype) :: t ->
                let str = data ^ " " ^ order_by_to_string ordertype in
                build t (str :: new_list)
          in

          build order_by []
        in

        " ORDER BY " ^ String.concat ", " as_string_list
    in

    let sql =
      "SELECT " ^ to_select ^ " FROM " ^ table_name ^ where_sql ^ order_sql
    in

    (* FIXME add back as a cli option? *)
    (* print_endline ("SQL === " ^ sql); *)
    let stmt = Sqlite3.prepare db sql in
    let data_vector = Queue.create () in

    while Sqlite3.step stmt = Sqlite3.Rc.ROW do
      let value = Sqlite3.column stmt 0 in

      match Sqlite3.Data.to_int value with
      | Some n -> Queue.add (Int n) data_vector
      | None -> (
          match Sqlite3.Data.to_string value with
          | Some s ->
              Queue.add (String s) data_vector
          | None -> failwith "didnt get int or string")
    done;

    List.of_seq (Queue.to_seq data_vector)

  (* ------------ *)

  let select_ints_where ?(or_conditional = false) ?(order_by = []) db
      ~table_name ~to_select ~where =
    let strings_or_ints =
      get_data_helper ~or_conditional ~order_by db ~table_name ~where ~to_select
    in

    let rec ints list new_list =
      match list with
      | [] -> new_list
      | h :: t -> (
          match h with
          | String _ -> failwith "expected ints"
          | Int x -> ints t (x :: new_list))
    in

    List.rev (ints strings_or_ints [])

  let select_strings_where ?(or_conditional = false) ?(order_by = []) db
      ~table_name ~to_select ~where =
    let strings_or_ints =
      get_data_helper ~or_conditional ~order_by db ~table_name ~where ~to_select
    in

    let rec strings list new_list =
      match list with
      | [] -> new_list
      | h :: t -> (
          match h with
          | String x -> strings t (x :: new_list)
          | Int _ -> failwith "expected strings")
    in

    List.rev (strings strings_or_ints [])
end
