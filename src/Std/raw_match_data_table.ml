module type Fetchable_Data = sig
  module Fetch : sig
    val latest_match_number : Sqlite3.db -> float
    val average_auto_game_pieces : Sqlite3.db -> float
    val average_auto_cones : Sqlite3.db -> float
    val average_auto_cubes : Sqlite3.db -> float
    val average_auto_cones : Sqlite3.db -> float
  end
end

module type Table_type = sig
  include Db_utils.Generic_Table
  (* include Fetchable_Data *)
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

  let primary_keys = [ Team_number; Team_name; Match_Number; Scouter_Name ]

  let create_table db =
    Db_utils.create_table db ~table_name ~colums:colums_in_order ~primary_keys
      ~to_name:colum_name ~to_datatype:colum_datatype

  let drop_table () = Db_utils.Failed

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

    let open Schema.Reader.RawMatchData in
    let values =
      Printf.sprintf
        "%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, \n\
        \         %s, %s, %s, %s"
        (match_data |> team_number_get |> string_of_int)
        (match_data |> team_name_get)
        (match_data |> match_number_get |> string_of_int)
        (match_data |> scouter_name_get)
        (*  *)
        (match_data |> incap_get |> string_of_bool)
        (match_data |> playing_defense_get |> string_of_bool)
        (match_data |> notes_get)
        (*  *)
        (match_data |> auto_climb_get |> climb_to_string)
        (match_data |> auto_cone_high_get |> string_of_int)
        (match_data |> auto_cone_mid_get |> string_of_int)
        (match_data |> auto_cone_low_get |> string_of_int)
        (match_data |> auto_cube_high_get |> string_of_int)
        (match_data |> auto_cube_mid_get |> string_of_int)
        (match_data |> auto_cube_low_get |> string_of_int)
        (*  *)
        (match_data |> tele_climb_get |> climb_to_string)
        (match_data |> tele_cone_high_get |> string_of_int)
        (match_data |> tele_cone_mid_get |> string_of_int)
        (match_data |> tele_cone_low_get |> string_of_int)
        (match_data |> tele_cube_high_get |> string_of_int)
        (match_data |> tele_cube_mid_get |> string_of_int)
        (match_data |> tele_cube_low_get |> string_of_int)
    in

    let sql = "INSERT INTO " ^ table_name ^ " VALUES(" ^ values ^ ")" in

    match Sqlite3.exec db sql with
    | Sqlite3.Rc.OK -> Db_utils.Successful
    | _ -> Db_utils.Failed

  module Fetch = struct
    let get x = ""
  end
end
