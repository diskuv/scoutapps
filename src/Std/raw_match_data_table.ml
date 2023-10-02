module type Fetchable_Data = sig
  module Fetch : sig
    val latest_match_number : Sqlite3.db -> int option

    val missing_data :
      Sqlite3.db -> (int * SquirrelScout_Std_intf.Types.robot_position list) list

    val all_match_numbers_in_db : Sqlite3.db -> int list
    val teams_for_match_number : Sqlite3.db -> int -> int list
    (* FIXME: add missing match data function  *)
    (* val average_auto_game_pieces : Sqlite3.db -> float
       val average_auto_cones : Sqlite3.db -> float
       val average_auto_cubes : Sqlite3.db -> float
       val average_auto_cones : Sqlite3.db -> float *)
  end
end

module type Table_type = sig
  include Db_utils.Generic_Table
  include Fetchable_Data
end

module Table : Table_type = struct
  let x = ""
  let table_name = "raw_match_data"

  type colums =
    (* [not game specific] generic info *)
    | Team_number
    | Team_name
    | Match_Number
    | Scouter_Name
    | (*[not game specific] misc data *)
      Incap
    | Playing_Defense
    | Notes
    | (* [Game specific] auto*)
      Auto_climb
    | Auto_Cone_high
    | Auto_Cone_mid
    | Auto_Cone_low
    | Auto_Cube_high
    | Auto_Cube_mid
    | Auto_Cube_low
    | (* [Game specific] tele  *)
      Tele_climb
    | Tele_Cone_high
    | Tele_Cone_mid
    | Tele_Cone_low
    | Tele_Cube_high
    | Tele_Cube_mid
    | Tele_Cube_low

  (* FIXME  *)
  let colum_name = function
    | Team_number -> "team_number"
    | Team_name -> "team_name"
    | Match_Number -> "match_number"
    | Scouter_Name -> "scouter_name"
    (*  *)
    | Incap -> "incap"
    | Playing_Defense -> "playing_defense"
    | Notes -> "notes"
    (*  *)
    | Auto_climb -> "auto_climb"
    | Auto_Cone_high -> "auto_cone_high"
    | Auto_Cone_mid -> "auto_cone_mid"
    | Auto_Cone_low -> "auto_cone_low"
    | Auto_Cube_high -> "auto_cube_high"
    | Auto_Cube_mid -> "auto_cube_mid"
    | Auto_Cube_low -> "auto_cube_low"
    (*  *)
    | Tele_climb -> "tele_climb"
    | Tele_Cone_high -> "tele_cone_high"
    | Tele_Cone_mid -> "tele_cone_mid"
    | Tele_Cone_low -> "tele_cone_low"
    | Tele_Cube_high -> "tele_cube_high"
    | Tele_Cube_mid -> "tele_cube_mid"
    | Tele_Cube_low -> "tele_cube_low"

  (* FIXME *)
  let colum_datatype = function
    | Team_number -> "INT"
    | Team_name -> "TEXT"
    | Match_Number -> "INT"
    | Scouter_Name -> "TEXT"
    (*  *)
    | Incap -> "INT"
    | Playing_Defense -> "INT"
    | Notes -> "TEXT"
    (*  *)
    | Auto_climb -> "TEXT"
    | Auto_Cone_high -> "INT"
    | Auto_Cone_mid -> "INT"
    | Auto_Cone_low -> "INT"
    | Auto_Cube_high -> "INT"
    | Auto_Cube_mid -> "INT"
    | Auto_Cube_low -> "INT"
    (*  *)
    | Tele_climb -> "TEXT"
    | Tele_Cone_high -> "INT"
    | Tele_Cone_mid -> "INT"
    | Tele_Cone_low -> "INT"
    | Tele_Cube_high -> "INT"
    | Tele_Cube_mid -> "INT"
    | Tele_Cube_low -> "INT"

  (* FIXME *)
  let colums_in_order =
    [
      Team_number;
      Team_name;
      Match_Number;
      Scouter_Name;
      (*  *)
      Incap;
      Playing_Defense;
      Notes;
      (*  *)
      Auto_climb;
      Auto_Cone_high;
      Auto_Cone_mid;
      Auto_Cone_low;
      Auto_Cube_high;
      Auto_Cube_mid;
      Auto_Cube_low;
      (*  *)
      Tele_climb;
      Tele_Cone_high;
      Tele_Cone_mid;
      Tele_Cone_low;
      Tele_Cube_high;
      Tele_Cube_mid;
      Tele_Cube_low;
    ]

  let primary_keys = [ Team_number; Match_Number; Scouter_Name ]

  let create_table db =
    Db_utils.create_table db ~table_name ~colums:colums_in_order ~primary_keys
      ~to_name:colum_name ~to_datatype:colum_datatype

  let drop_table db = Db_utils.Failed

  let insert_record db capnp_string =
    let module Schema = Schema.Make (Capnp.BytesMessage) in
    let match_data =
      match
        Capnp.Codecs.FramedStream.get_next_frame
          (Capnp.Codecs.FramedStream.of_string ~compression:`None capnp_string)
      with
      | Result.Ok message -> Schema.Reader.RawMatchData.of_message message
      | Result.Error _ -> failwith "could not decode capnp data"
    in

    let climb_to_string = function
      | Schema.Reader.Climb.Docked -> "DOCKED"
      | Schema.Reader.Climb.Engaged -> "ENGAGED"
      | Schema.Reader.Climb.None -> "NONE"
      | Schema.Reader.Climb.Undefined _ -> "UNDEFINED"
    in

    let string_to_cmd_line_form s = "\"" ^ s ^ "\"" in

    let bool_to_string_as_num bool =
      match bool with true -> "1" | false -> "0"
    in

    let open Schema.Reader.RawMatchData in
    (* RELEASE_BLOCKER: jonahbeckford@

       This is not how to insert data into a database.
       It is INCREDIBLY unsafe, although the OCaml library
       does not give you any examples of how to do it safely
       with prepared statements. All someone would need to
       do is make a special QR code and they could hack your phone. *)
    let values =
      Printf.sprintf
        "%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, \n\
        \         %s, %s, %s, %s"
        (match_data |> team_number_get |> string_of_int)
        (match_data |> team_name_get |> string_to_cmd_line_form)
        (match_data |> match_number_get |> string_of_int)
        (match_data |> scouter_name_get |> string_to_cmd_line_form)
        (*  *)
        (match_data |> incap_get |> bool_to_string_as_num)
        (match_data |> playing_defense_get |> bool_to_string_as_num)
        (match_data |> notes_get |> string_to_cmd_line_form)
        (*  *)
        (match_data |> auto_climb_get |> climb_to_string
       |> string_to_cmd_line_form)
        (match_data |> auto_cone_high_get |> string_of_int)
        (match_data |> auto_cone_mid_get |> string_of_int)
        (match_data |> auto_cone_low_get |> string_of_int)
        (match_data |> auto_cube_high_get |> string_of_int)
        (match_data |> auto_cube_mid_get |> string_of_int)
        (match_data |> auto_cube_low_get |> string_of_int)
        (*  *)
        (match_data |> tele_climb_get |> climb_to_string
       |> string_to_cmd_line_form)
        (match_data |> tele_cone_high_get |> string_of_int)
        (match_data |> tele_cone_mid_get |> string_of_int)
        (match_data |> tele_cone_low_get |> string_of_int)
        (match_data |> tele_cube_high_get |> string_of_int)
        (match_data |> tele_cube_mid_get |> string_of_int)
        (match_data |> tele_cube_low_get |> string_of_int)
    in

    let sql = "INSERT INTO " ^ table_name ^ " VALUES(" ^ values ^ ")" in

    Logs.debug (fun l -> l "raw_match_table sql: %s" sql);

    match Sqlite3.exec db sql with
    | Sqlite3.Rc.OK -> Db_utils.Successful
    | _ -> Db_utils.Failed

  module Fetch = struct
    let latest_match_number db =
      let to_select = colum_name Match_Number in

      let where = [] in

      let order_by = [ (colum_name Match_Number, Db_utils.Select.DESC) ] in

      let result =
        Db_utils.Select.select_ints_where db ~table_name ~to_select ~where
          ~order_by
      in

      match result with [] -> None | x :: _ -> Some x

    let all_match_numbers_in_db db =
      let to_select = colum_name Match_Number in

      Db_utils.Select.select_ints_where db ~table_name ~to_select ~where:[]

    let teams_for_match_number db match_num =
      let to_select = colum_name Team_number in
      let where =
        [ (colum_name Match_Number, Db_utils.Select.Int match_num) ]
      in

      Db_utils.Select.select_ints_where db ~table_name ~to_select ~where

    let missing_data db =
      let scheduled_matches =
        Match_schedule_table.Table.Fetch.get_all_match_numbers db
      in

      let all_matches_in_db = all_match_numbers_in_db db in

      let latest_match = latest_match_number db in

      match latest_match with
      | None -> []
      | Some l_match ->
          let num_entries_for_match_num match_num =
            let to_select = colum_name Match_Number in
            let where =
              [ (colum_name Match_Number, Db_utils.Select.Int match_num) ]
            in

            List.length
              (Db_utils.Select.select_ints_where db ~table_name ~to_select
                 ~where)
          in

          let rec build_missing_lst lst current_match =
            match current_match > l_match with
            | true -> lst
            | false ->
                let num_entries = num_entries_for_match_num current_match in
                let new_lst =
                  if num_entries < 6 then current_match :: lst else lst
                in

                build_missing_lst new_lst (current_match + 1)
          in

          let missing_data_matches = build_missing_lst [] 1 in

          let teams_missing_per_match_list =
            let rec build matches_missing_data lst =
              match matches_missing_data with
              | [] -> lst
              | match_n :: l ->
                  let teams_scheduled =
                    Match_schedule_table.Table.Fetch.get_all_teams_for_match db
                      match_n
                  in
                  let teams_actually_in_db =
                    teams_for_match_number db match_n
                  in

                  let teams_missing_for_this_match =
                    let rec fliter all_teams missing =
                      match all_teams with
                      | x :: l ->
                          if List.exists (fun a -> a == x) teams_actually_in_db
                          then fliter l missing
                          else fliter l (x :: missing)
                      | [] -> missing
                    in

                    fliter teams_scheduled []
                  in

                  build l ((match_n, teams_missing_for_this_match) :: lst)
            in

            build missing_data_matches []
          in

          let positions_missing_per_match =
            let rec build teams_list pose_list =
              match teams_list with
              | (match_n, lst) :: l ->
                  let rec build_pos_list team_nums pos_lst =
                    match team_nums with
                    | [] -> pos_lst
                    | x :: l ->
                        let p =
                          Match_schedule_table.Table.Fetch
                          .get_position_for_team_and_match db x match_n
                        in
                        build_pos_list l (p :: pos_lst)
                  in

                  let poses = build_pos_list lst [] in

                  build l ((match_n, poses) :: pose_list)
              | [] -> pose_list
            in

            build teams_missing_per_match_list []
          in

          let de_optioned_positions =
            let rec build pose_lst no_opt_lst =
              match pose_lst with
              | [] -> no_opt_lst
              | (match_n, opt_poses) :: l ->
                  let rec de_opt_lst opt_poses de_opted =
                    match opt_poses with
                    | [] -> de_opted
                    | Some x :: l ->
                        let d = x :: de_opted in
                        de_opt_lst l d
                    | None :: l -> de_opt_lst l de_opted
                  in

                  let non_optioned = de_opt_lst opt_poses [] in

                  build l ((match_n, non_optioned) :: no_opt_lst)
            in

            build positions_missing_per_match []
          in

          de_optioned_positions
  end
end
