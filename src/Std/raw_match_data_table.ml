let table_name = "raw_match_data"

let create_table_sql_cols =
  [|
    "team_number INT";
    "team_name TEXT";
    "match INT";
    "scouter_name TEXT";
    (* auto *)
    "auto_moblity INT";
    "auto_climb TEXT";
    "auto_cone_high INT";
    "auto_cone_mid INT";
    "auto_cone_low INT";
    "auto_cube_high INT";
    "auto_cube_mid INT";
    "auto_cube_low INT";
    (* tele *)
    "tele_climb TEXT";
    "tele_cone_high INT";
    "ele_cone_mid INT";
    "tele_cone_low INT";
    "tele_cube_high INT";
    "tele_cube_mid INT";
    "tele_cube_low INT";
    (* mics *)
    "incap INT";
    "playing_defense INT";
    "notes TEXT";
  |]

let create_table db =
  let initial_sql = "CREATE TABLE " ^ table_name ^ "(" in

  let rec table_colums_as_string_list i list =
    if i == Array.length create_table_sql_cols then list
    else
      let new_list = List.append list [ create_table_sql_cols.(i) ] in
      table_colums_as_string_list (i + 1) new_list
  in

  let colum_list = table_colums_as_string_list 0 [] in

  let primary_keys = "PRIMARY KEY(team_number,match,scouter_name)" in

  let finilazed_sql =
    initial_sql ^ String.concat "," colum_list ^ "," ^ primary_keys ^ ") STRICT"
  in

  Db_utils.create_table_helper db finilazed_sql table_name

(* upsert *)
(* return primary key option None or primary key *)
let insert_db_record db capnp_data =
  let open Sqlite3 in
  let open Db_utils in
  let module Schema = Schema.Make (Capnp.BytesMessage) in
  let match_data =
    match
      Capnp.Codecs.FramedStream.get_next_frame
        (Capnp.Codecs.FramedStream.of_string ~compression:`None capnp_data)
    with
    | Result.Ok message -> Schema.Reader.RawMatchData.of_message message
    | Result.Error _ -> failwith "could not decode capnp data"
  in

  let insert_sql =
    "INSERT INTO " ^ table_name
    ^ " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
  in

  let climb_to_string = function
    | Schema.Reader.Climb.Docked -> "DOCKED"
    | Schema.Reader.Climb.Engaged -> "ENGAGED"
    | Schema.Reader.Climb.None -> "NONE"
    | Schema.Reader.Climb.Undefined _ -> "UNDEFINED"
  in

  let open Schema.Reader.RawMatchData in
  let insert_stmt = prepare db insert_sql in

  (* let bind_in = DB_operation_utils.bind_insert_stmt insert_stmt db  *)
  let bind_insert_stmt =
    Db_utils.bind_insert_statement insert_stmt db
  in

  bind_insert_stmt 1 (match_data |> team_number_get |> db_int);
  bind_insert_stmt 2 (match_data |> team_name_get |> db_text);
  bind_insert_stmt 3 (match_data |> match_number_get |> db_int);
  bind_insert_stmt 4 (match_data |> scouter_name_get |> db_text);

  (* auto *)
  bind_insert_stmt 5 (match_data |> auto_mobility_get |> db_bool);
  bind_insert_stmt 6 (match_data |> auto_climb_get |> climb_to_string |> db_text);

  bind_insert_stmt 7 (match_data |> auto_cone_high_get |> db_int);
  bind_insert_stmt 8 (match_data |> auto_cone_mid_get |> db_int);
  bind_insert_stmt 9 (match_data |> auto_cone_low_get |> db_int);

  bind_insert_stmt 10 (match_data |> auto_cube_high_get |> db_int);
  bind_insert_stmt 11 (match_data |> auto_cube_mid_get |> db_int);
  bind_insert_stmt 12 (match_data |> auto_cube_low_get |> db_int);

  (* tele *)
  bind_insert_stmt 13
    (match_data |> tele_climb_get |> climb_to_string |> db_text);

  bind_insert_stmt 14 (match_data |> tele_cone_high_get |> db_int);
  bind_insert_stmt 15 (match_data |> tele_cone_mid_get |> db_int);
  bind_insert_stmt 16 (match_data |> tele_cone_low_get |> db_int);

  bind_insert_stmt 17 (match_data |> tele_cube_high_get |> db_int);
  bind_insert_stmt 18 (match_data |> tele_cube_mid_get |> db_int);
  bind_insert_stmt 19 (match_data |> tele_cube_low_get |> db_int);

  (* misc *)
  bind_insert_stmt 20 (match_data |> incap_get |> db_bool);
  bind_insert_stmt 21 (match_data |> playing_defense_get |> db_bool);
  bind_insert_stmt 22 (match_data |> notes_get |> db_text);

  match step insert_stmt with
  | Rc.DONE ->
      let row_id = Sqlite3.last_insert_rowid db in
      Printf.printf
        "SUCCESSFULLY INSERTED RECORD INTO: \n\
        \          *TABLE=%S \n\
        \          *row_id=%d\n\
        \          *team_number=%d \n\
        \          *match_number=%d \n\
        \          *scouter_name=%s \n"
        table_name (Int64.to_int row_id)
        (team_number_get match_data)
        (match_number_get match_data)
        (scouter_name_get match_data);

      Some
        ( team_number_get match_data,
          match_number_get match_data,
          scouter_name_get match_data )
  | _ -> failwith "could not insert into raw match data table"

(* get data functions *)

let get_average_cone_high db team =
  Db_utils.select_int_field_where db ~table_name
    ~to_select:"auto_cone_high"
    ~where:[ ("team_number", string_of_int team) ]
