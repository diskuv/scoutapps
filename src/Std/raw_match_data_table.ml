module type Fetchable_Data = sig
  val already_contains_record :
    Sqlite3.db ->
    team_number:int ->
    match_number:int ->
    scouter_name:string ->
    bool

  module Fetch : sig
    val latest_match_number : Sqlite3.db -> int option

    val missing_data :
      Sqlite3.db ->
      (int * SquirrelScout_Std_intf.Types.robot_position list) list

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
    (*| Alliance*)
    (* [Game specific] auto*)
    | Starting_Position
    | Wing_Note1
    | Wing_Note2
    | Wing_Note3
    | Center_Note1
    | Center_Note2
    | Center_Note3
    | Center_Note4
    | Center_Note5
    | Auto_Amp_Score
    | Auto_Amp_Miss
    | Auto_Speaker_Score
    | Auto_Speaker_Miss
    | Auto_Leave
    (* [Game specific] tele  *)
    | Tele_Speaker_Score
    | Tele_Speaker_Miss
    | Tele_Amp_Score
    | Tele_Amp_Miss
    | Distance
    | Tele_Breakdown
    | Tele_Pickup
    | Endgame_Climb
    | Endgame_Trap

  (* FIXME  *)
  let colum_name = function
    | Team_number -> "team_number"
    | Team_name -> "team_name"
    | Match_Number -> "match_number"
    | Scouter_Name -> "scouter_name"
    (*| Alliance -> "alliance"*)
    (*  *)
    | Starting_Position -> "starting_position"
    | Wing_Note1 -> "wing_note1"
    | Wing_Note2 -> "wing_note2"
    | Wing_Note3 -> "wing_note3"
    | Center_Note1 -> "center_note1"
    | Center_Note2 -> "center_note2"
    | Center_Note3 -> "center_note3"
    | Center_Note4 -> "center_note4"
    | Center_Note5 -> "center_note5"
    | Auto_Amp_Score -> "auto_amp_score"
    | Auto_Amp_Miss -> "auto_amp_miss"
    | Auto_Speaker_Score -> "auto_speaker_score"
    | Auto_Speaker_Miss -> "auto_speaker_miss"
    | Auto_Leave -> "auto_leave"
    (*  *)
    | Tele_Speaker_Score -> "tele_speaker_score"
    | Tele_Speaker_Miss -> "tele_speaker_miss"
    | Tele_Amp_Score -> "tele_amp_score"
    | Tele_Amp_Miss -> "tele_amp_miss"
    | Distance -> "distance"
    | Tele_Breakdown -> "tele_breakdown"
    | Tele_Pickup -> "tele_pickup"
    | Endgame_Climb -> "endgame_climb"
    | Endgame_Trap -> "endgame_trap"

  (* FIXME *)
  let colum_datatype = function
    | Team_number -> "INT"
    | Team_name -> "TEXT"
    | Match_Number -> "INT"
    | Scouter_Name -> "TEXT"
    (*| Alliance -> "TEXT"*)
    (*  *)
    | Starting_Position -> "TEXT"
    | Wing_Note1 -> "TEXT"
    | Wing_Note2 -> "TEXT"
    | Wing_Note3 -> "TEXT"
    | Center_Note1 -> "TEXT"
    | Center_Note2 -> "TEXT"
    | Center_Note3 -> "TEXT"
    | Center_Note4 -> "TEXT"
    | Center_Note5 -> "TEXT"
    | Auto_Amp_Score -> "INT"
    | Auto_Amp_Miss -> "INT"
    | Auto_Speaker_Score -> "INT"
    | Auto_Speaker_Miss -> "INT"
    | Auto_Leave -> "TEXT"
    (*  *)
    | Tele_Speaker_Score -> "INT"
    | Tele_Speaker_Miss -> "INT"
    | Tele_Amp_Score -> "INT"
    | Tele_Amp_Miss -> "INT"
    | Distance -> "Text"
    | Tele_Breakdown -> "TEXT"
    | Tele_Pickup -> "TEXT"
    | Endgame_Climb -> "TEXT"
    | Endgame_Trap -> "TEXT"

  (* FIXME *)
  let colums_in_order =
    [
      Team_number;
      Team_name;
      Match_Number;
      Scouter_Name;
      (*Alliance;*)
      (* Auto *)
      Starting_Position;
      Wing_Note1;
      Wing_Note2;
      Wing_Note3;
      Center_Note1;
      Center_Note2;
      Center_Note3;
      Center_Note4;
      Center_Note5;
      Auto_Amp_Score;
      Auto_Amp_Miss;
      Auto_Speaker_Score;
      Auto_Speaker_Miss;
      Auto_Leave;
      (* Teleop *)
      Tele_Speaker_Score;
      Tele_Speaker_Miss;
      Tele_Amp_Score;
      Tele_Amp_Miss;
      Distance;
      Tele_Breakdown;
      Tele_Pickup;
      Endgame_Climb;
      Endgame_Trap;
    ]

  let primary_keys = [ Team_number; Match_Number; Scouter_Name ]

  let create_table db =
    Db_utils.create_table db ~table_name ~colums:colums_in_order ~primary_keys
      ~to_name:colum_name ~to_datatype:colum_datatype

  let drop_table db = Db_utils.Failed

  let already_contains_record db ~team_number ~match_number ~scouter_name =
    let to_select = colum_name Team_number in
    let where =
      [
        (colum_name Team_number, Db_utils.Select.Int team_number);
        (colum_name Match_Number, Db_utils.Select.Int match_number);
        (colum_name Scouter_Name, Db_utils.Select.String scouter_name);
      ]
    in

    let result =
      Db_utils.Select.select_ints_where db ~table_name ~to_select ~where
    in

    match result with _ :: [] -> true | _ -> false

  let insert_record db capnp_string =
    let module ProjectSchema = Schema.Make (Capnp.BytesMessage) in
    let match_data =
      match
        Capnp.Codecs.FramedStream.get_next_frame
          (Capnp.Codecs.FramedStream.of_string ~compression:`None capnp_string)
      with
      | Result.Ok message -> ProjectSchema.Reader.RawMatchData.of_message message
      | Result.Error _ -> failwith "could not decode capnp data"
    in

    let position_to_string : ProjectSchema.Reader.SPosition.t -> string = function
      | AmpSide -> "AMPSIDE"
      | Center -> "CENTER"
      | SourceSide -> "SOURCESIDE"
      | Undefined _ -> "UNDEFINED"
    in

    let breakdown_to_string : ProjectSchema.Reader.TBreakdown.t -> string = function
      | None -> "NONE"
      | Tipped -> "TIPPED"
      | MechanicalFailure -> "MECHANICAL_FAILURE"
      | Incapacitated -> "INCAPACITATED"
      | Undefined _ -> "NONE"
    in

    let teleopClimb_to_string : ProjectSchema.Reader.EClimb.t -> string = function
      | Success -> "SUCCESS"
      | Failed -> "FAILED"
      | DidNotAttempt -> "DID_NOT_ATTEMPT"
      | Harmony -> "HARMONY"
      | Parked -> "PARKED"
      | Undefined _ -> "UNDEFINED"
    in

    let alliance_to_string : ProjectSchema.Reader.RobotPosition.t -> string = function
      | Red1 -> "RED1"
      | Red2 -> "RED2"
      | Red3 -> "RED3"
      | Blue1 -> "BLUE1"
      | Blue2 -> "BLUE2"
      | Blue3 -> "BLUE3"
      | Undefined _ -> "UNDEFINED"
    in

    let string_to_cmd_line_form s = "\"" ^ s ^ "\"" in

    let bool_to_string_as_num bool =
      match bool with true -> "1" | false -> "0"
    in

    let open ProjectSchema.Reader.RawMatchData in
    let team_number = match_data |> team_number_get in
    let match_number = match_data |> match_number_get in
    let scouter_name = match_data |> scouter_name_get in

    let record_already_exists =
      already_contains_record db ~team_number ~match_number ~scouter_name
    in
    Format.eprintf "auto_speaker_miss_get = %d@." (auto_speaker_miss_get match_data);

    if record_already_exists then Db_utils.Successful
    else
      (* RELEASE_BLOCKER: jonahbeckford@

         This is not how to insert data into a database.
         It is INCREDIBLY unsafe, although the OCaml library
         does not give you any examples of how to do it safely
         with prepared statements. All someone would need to
         do is make a special QR code and they could hack your phone. *)
      let values =
        Printf.sprintf
        "%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, \n\
        \         %s, %s, %s, %s, %s, %s, %s, %s, %s, %s"
        (match_data |> team_number_get |> string_of_int)
        (match_data |> team_name_get |> string_to_cmd_line_form)
        (match_data |> match_number_get |> string_of_int)
        (match_data |> scouter_name_get |> string_to_cmd_line_form)
        (*(match_data |> alliance_color_get |> alliance_to_string |> string_to_cmd_line_form)*)
        (*  *)
        (match_data |> starting_position_get |> position_to_string
       |> string_to_cmd_line_form)
        (match_data |> wing_note1_get |> bool_to_string_as_num)
        (match_data |> wing_note2_get |> bool_to_string_as_num)
        (match_data |> wing_note3_get |> bool_to_string_as_num)
        (match_data |> center_note1_get |> bool_to_string_as_num)
        (match_data |> center_note2_get |> bool_to_string_as_num)
        (match_data |> center_note3_get |> bool_to_string_as_num)
        (match_data |> center_note4_get |> bool_to_string_as_num)
        (match_data |> center_note5_get |> bool_to_string_as_num)
        (match_data |> auto_amp_score_get |> string_of_int)
        (match_data |> auto_amp_miss_get |> string_of_int)
        (match_data |> auto_speaker_score_get |> string_of_int)
        (match_data |> auto_speaker_miss_get |> string_of_int)
        (match_data |> auto_leave_get |> bool_to_string_as_num)
        (*  *)
        (match_data |> tele_speaker_score_get |> string_of_int)
        (match_data |> tele_speaker_miss_get |> string_of_int)
        (match_data |> tele_amp_score_get |> string_of_int)
        (match_data |> tele_amp_miss_get |> string_of_int)
        (match_data |> distance_get |> string_to_cmd_line_form)
        (match_data |> tele_breakdown_get |> breakdown_to_string
       |> string_to_cmd_line_form)
        (match_data |> tele_pickup_get |> string_to_cmd_line_form)
        (match_data |> endgame_climb_get |> teleopClimb_to_string
       |> string_to_cmd_line_form)
        (match_data |> endgame_trap_get |> bool_to_string_as_num)
      in

      let sql = "INSERT INTO " ^ table_name ^ " VALUES(" ^ values ^ ")" in

      Logs.debug (fun l -> l "raw_match_table sql: %s" sql);

      match Sqlite3.exec db sql with
      | Sqlite3.Rc.OK ->
          print_endline "exec successful";
          Db_utils.Successful
      | r ->
          Db_utils.formatted_error_message db r
            "failed to exec raw_match_data insert sql";
          Db_utils.Failed

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
