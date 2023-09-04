module type Match_schedule_table_sig = sig
  type robot_position 

  val robot_position_to_string : robot_position -> string

  val fill_database_from_json : Sqlite3.db -> string -> Db_utils.return_code
  
  module Fetch : sig
    val get_team_for_match_and_position : Sqlite3.db -> int -> robot_position -> int option 
    val get_all_matches_for_team : Sqlite3.db -> int -> int list 
  end
end

module type Complete_Table = sig
include Db_utils.Generic_Table
include Match_schedule_table_sig 
end 


module Table : Complete_Table = struct
  let table_name = "match_schudle_table"

  type colums =
    | Match_number
    | Red_1
    | Red_2
    | Red_3
    | Blue_1
    | Blue_2
    | Blue_3

  (* FIXME:  *)
  let colum_name = function
    | Match_number -> "match_number"
    | Red_1 -> "Red_1"
    | Red_2 -> "Red_2"
    | Red_3 -> "Red_3"
    | Blue_1 -> "blue_1"
    | Blue_2 -> "blue_2"
    | Blue_3 -> "blue_3"

  (* FIXME *)
  let colum_datatype = function
    | Match_number -> "INT"
    | Red_1 -> "INT"
    | Red_2 -> "INT"
    | Red_3 -> "INT"
    | Blue_1 -> "INT"
    | Blue_2 -> "INT"
    | Blue_3 -> "INT"

  let colums_in_order =
    [ Match_number; Red_1; Red_2; Red_3; Blue_1; Blue_2; Blue_3 ]

  let primary_keys = [ Match_number ]

  let create_table db =
    Db_utils.create_table db ~table_name ~colums:colums_in_order ~primary_keys
      ~to_name:colum_name ~to_datatype:colum_datatype

  let drop_table () = Db_utils.Failed

  (* FIXME: Dont insert indivisual records, load data from json *)
  let insert_record _db _string = Db_utils.Failed

  type robot_position = Red_1 | Red_2 | Red_3 | Blue_1 | Blue_2 | Blue_3

  let robot_position_to_string = function
    | Red_1 -> "red_1"
    | Red_2 -> "red_2"
    | Red_3 -> "red_3"
    | Blue_1 -> "blue_1"
    | Blue_2 -> "blue_2"
    | Blue_3 -> "blue_3"

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

      let bind_insert_stmt = Db_utils.bind_insert_statement insert_stmt db in

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
          Db_utils.formatted_error_message db r
            ("failed to insert record into " ^ table_name)
    in

    List.iter (fun a -> insert_indivisual_record a) records_list; 

    (* FIXME *)
    Db_utils.Successful

  module Fetch = struct
  let get_team_for_match_and_position db match_number position =
    let to_select = robot_position_to_string position in
    let where =
      [ (colum_name Match_number, Db_utils.Select.Int match_number) ]
    in

    let result =
      Db_utils.Select.select_ints_where db ~table_name ~to_select ~where
    in

    
  match result with (x :: []) -> Some x | _ -> None

  let get_all_matches_for_team db team =
    let to_select = colum_name Match_number in

    let team = Db_utils.Select.Int team in

    let where =
      [
        (colum_name Red_1, team);
        (colum_name Red_2, team);
        (colum_name Red_3, team);
        (colum_name Blue_1, team);
        (colum_name Blue_2, team);
        (colum_name Blue_3, team);
      ]
    in

    Db_utils.Select.select_ints_where db ~or_conditional:true ~table_name
      ~to_select ~where

  end 
end
