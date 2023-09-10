module type Match_schedule_table_sig = sig
  type robot_position = Red_1 | Red_2 | Red_3 | Blue_1 | Blue_2 | Blue_3

  val robot_position_to_string : robot_position -> string
  val fill_database_from_json : Sqlite3.db -> string -> Db_utils.return_code

  module Fetch : sig
    val get_team_for_match_and_position :
      Sqlite3.db -> int -> robot_position -> int option

    val get_all_matches_for_team : Sqlite3.db -> int -> int list
    val get_all_teams_for_match : Sqlite3.db -> int -> int list
    val get_all_match_numbers : Sqlite3.db -> int list

    val get_position_for_team_and_match :
      Sqlite3.db -> int -> int -> robot_position option

    val get_whole_schedule :
      Sqlite3.db -> (int * int * int * int * int * int * int) list
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

    let insert_if_not_exist data =
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

      let match_exists_check num =
        let to_select = colum_name Match_number in
        let where = [ (colum_name Match_number, Db_utils.Select.Int num) ] in

        let result =
          Db_utils.Select.select_ints_where db ~table_name ~to_select ~where
        in

        match result with x :: [] -> x == match_number | _ -> false
      in

      if match_exists_check match_number then ()
      else
        let open Sqlite3 in
        let sql = "INSERT INTO " ^ table_name ^ " VALUES(?,?,?,?,?,?,?)" in
        let insert_stmt = prepare db sql in

        let bind_insert_stmt = Db_utils.bind_insert_statement insert_stmt db in

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

    List.iter (fun a -> insert_if_not_exist a) records_list;

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

      match result with x :: [] -> Some x | _ -> None

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

      let order_by = [ (colum_name Match_number, Db_utils.Select.ASC) ] in

      Db_utils.Select.select_ints_where db ~or_conditional:true ~table_name
        ~to_select ~where ~order_by

    let get_all_match_numbers db =
      let to_select = colum_name Match_number in
      let where = [] in
      let order_by = [ (colum_name Match_number, Db_utils.Select.ASC) ] in

      let res =
        Db_utils.Select.select_ints_where db ~table_name ~to_select ~where
          ~order_by
      in

      res

    let get_all_teams_for_match db match_num =
      let r1 = get_team_for_match_and_position db match_num Red_1 in
      let r2 = get_team_for_match_and_position db match_num Red_2 in
      let r3 = get_team_for_match_and_position db match_num Red_3 in
      let b1 = get_team_for_match_and_position db match_num Blue_1 in
      let b2 = get_team_for_match_and_position db match_num Blue_2 in
      let b3 = get_team_for_match_and_position db match_num Blue_3 in

      let teams_list =
        let rec build lst optionals =
          match optionals with
          | Some x :: l ->
              let new_lst = x :: lst in
              build new_lst l
          | None :: l -> build lst l
          | [] -> lst
        in

        build [] [ r1; r2; r3; b1; b2; b3 ]
      in

      teams_list

    let get_position_for_team_and_match db team match_num =
      let exist_or_dummy_value = function Some n -> n | None -> 0 in

      let r1_team =
        get_team_for_match_and_position db match_num Red_1
        |> exist_or_dummy_value
      in
      let r2_team =
        get_team_for_match_and_position db match_num Red_2
        |> exist_or_dummy_value
      in
      let r3_team =
        get_team_for_match_and_position db match_num Red_3
        |> exist_or_dummy_value
      in

      let b1_team =
        get_team_for_match_and_position db match_num Blue_1
        |> exist_or_dummy_value
      in
      let b2_team =
        get_team_for_match_and_position db match_num Blue_2
        |> exist_or_dummy_value
      in
      let b3_team =
        get_team_for_match_and_position db match_num Blue_3
        |> exist_or_dummy_value
      in

      if r1_team == team then Some Red_1
      else if r2_team == team then Some Red_2
      else if r3_team == team then Some Red_3
      else if b1_team == team then Some Blue_1
      else if b2_team == team then Some Blue_2
      else if b3_team == team then Some Blue_3
      else None

    let get_whole_schedule db =
      let matches = get_all_match_numbers db in

      let rec fill_list lst pos =
        if List.length matches == pos then lst
        else
          let match_num = List.nth matches pos in

          let get_team_or_fail = function
            | Some x -> x
            | None -> failwith "somehow did not get a team number"
          in

          let red_1 =
            get_team_for_match_and_position db match_num Red_1
            |> get_team_or_fail
          in
          let red_2 =
            get_team_for_match_and_position db match_num Red_2
            |> get_team_or_fail
          in
          let red_3 =
            get_team_for_match_and_position db match_num Red_3
            |> get_team_or_fail
          in

          let blue_1 =
            get_team_for_match_and_position db match_num Blue_1
            |> get_team_or_fail
          in
          let blue_2 =
            get_team_for_match_and_position db match_num Blue_2
            |> get_team_or_fail
          in
          let blue_3 =
            get_team_for_match_and_position db match_num Blue_3
            |> get_team_or_fail
          in

          let new_lst =
            (match_num, red_1, red_2, red_3, blue_1, blue_2, blue_3) :: lst
          in

          fill_list new_lst (pos + 1)
      in

      let list = fill_list [] 0 in

      List.rev list
  end
end
