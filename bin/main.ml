module DB_operation_utils = struct
  let int64_of_bool = function false -> 0L | true -> 1L

  let formatted_error_message error message db =
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
end

module Raw_match_data_table = struct
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

  type climb = No_climb | Docked | Engaged

  let climb_to_string = function
    | No_climb -> "NONE"
    | Docked -> "DOCKED"
    | Engaged -> "Engaged"

  type raw_match_data_table_record = {
    (* team *)
    team_number : int64;
    team_name : string;
    match_number : int64;
    scouter_name : string;
    (* auto *)
    auto_mobility : bool;
    auto_climb : climb;
    auto_cone_high : int64;
    auto_cone_mid : int64;
    auto_cone_low : int64;
    auto_cube_high : int64;
    auto_cube_mid : int64;
    auto_cube_low : int64;
    (* tele *)
    tele_climb : climb;
    tele_cone_high : int64;
    tele_cone_mid : int64;
    tele_cone_low : int64;
    tele_cube_high : int64;
    tele_cube_mid : int64;
    tele_cube_low : int64;
    (* misc *)
    incap : bool;
    playing_defense : bool;
    notes : string;
  }

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
      initial_sql
      ^ String.concat "," colum_list
      ^ "," ^ primary_keys ^ ") STRICT"
    in

    match Sqlite3.exec db finilazed_sql with
    | Sqlite3.Rc.OK -> print_endline (table_name ^ "--- SUCCESSFULLY CREATED")
    | r ->
        print_endline (Sqlite3.Rc.to_string r);
        print_endline (Sqlite3.errmsg db)

  (* upsert *)
  (* return primary key option None or primary key *)
  let insert_db_record data db =
    let open Sqlite3 in
    let open DB_operation_utils in
    let insert_sql =
      "INSERT INTO " ^ table_name
      ^ " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    in

    let insert_stmt = prepare db insert_sql in

    (* let bind_in = DB_operation_utils.bind_insert_stmt insert_stmt db  *)
    let bind_insert_stmt =
      DB_operation_utils.bind_insert_statement insert_stmt db
    in

    bind_insert_stmt 1 (Data.INT data.team_number);
    bind_insert_stmt 2 (Data.TEXT data.team_name);
    bind_insert_stmt 3 (Data.INT data.match_number);
    bind_insert_stmt 4 (Data.TEXT data.scouter_name);

    (* auto *)
    bind_insert_stmt 5 (Data.INT (int64_of_bool data.auto_mobility));
    bind_insert_stmt 6 (Data.TEXT (climb_to_string data.auto_climb));

    bind_insert_stmt 7 (Data.INT data.auto_cone_high);
    bind_insert_stmt 8 (Data.INT data.auto_cone_mid);
    bind_insert_stmt 9 (Data.INT data.auto_cone_low);

    bind_insert_stmt 10 (Data.INT data.auto_cube_high);
    bind_insert_stmt 11 (Data.INT data.auto_cube_mid);
    bind_insert_stmt 12 (Data.INT data.auto_cube_low);

    (* tele *)
    bind_insert_stmt 13 (Data.TEXT (climb_to_string data.tele_climb));

    bind_insert_stmt 14 (Data.INT data.tele_cone_high);
    bind_insert_stmt 15 (Data.INT data.tele_cone_mid);
    bind_insert_stmt 16 (Data.INT data.tele_cone_low);

    bind_insert_stmt 17 (Data.INT data.tele_cube_high);
    bind_insert_stmt 18 (Data.INT data.tele_cube_mid);
    bind_insert_stmt 19 (Data.INT data.tele_cube_low);

    (* misc *)
    bind_insert_stmt 20 (Data.INT (int64_of_bool data.incap));
    bind_insert_stmt 21 (Data.INT (int64_of_bool data.playing_defense));
    bind_insert_stmt 22 (Data.TEXT data.notes);

    match step insert_stmt with
    | Rc.DONE ->
        let row_id = Sqlite3.last_insert_rowid db in
        print_endline
          ("Successfully added record... Row ID: " ^ Int64.to_string row_id)
    | r ->
        prerr_endline (Rc.to_string r);
        prerr_endline (errmsg db)

  (* get data functions *)
end

module Match_schudle_table = struct
  let table_name = "match_schudle_table"

  type robot_position = Red_1 | Red_2 | Red_3 | Blue_1 | Blue_2 | Blue_3

  let robot_position_to_string = function
    | Red_1 -> "red_1"
    | Red_2 -> "red_2"
    | Red_3 -> "red_3"
    | Blue_1 -> "blue_1"
    | Blue_2 -> "blue_2"
    | Blue_3 -> "blue_3"

  type match_schudle_record = {
    match_number : int64;
    red_1 : int64;
    red_2 : int64;
    red_3 : int64;
    blue_1 : int64;
    blue_2 : int64;
    blue_3 : int64;
  }

  let create_table db =
    let sql =
      "CREATE TABLE " ^ table_name
      ^ "(match_number INT, red_1 INT, red_2 INT, red_3 INT, blue_1 INT, \
         blue_2 INT, blue_3 INT)"
    in
    match Sqlite3.exec db sql with
    | Sqlite3.Rc.OK -> print_endline (table_name ^ "--- SUCCESSFULLY CREATED")
    | _ ->
        print_endline
          (table_name ^ "----- already exists---- continuing with program")

  let insert_match_schudle_record db match_schudle_record =
    let open Sqlite3 in
    let sql = "INSERT INTO " ^ table_name ^ " VALUES(?,?,?,?,?,?,?)" in
    let insert_stmt = prepare db sql in

    let bind_insert_stmt =
      DB_operation_utils.bind_insert_statement insert_stmt db
    in

    bind_insert_stmt 1 (Data.INT match_schudle_record.match_number);

    bind_insert_stmt 2 (Data.INT match_schudle_record.red_1);
    bind_insert_stmt 3 (Data.INT match_schudle_record.red_2);
    bind_insert_stmt 4 (Data.INT match_schudle_record.red_3);

    bind_insert_stmt 5 (Data.INT match_schudle_record.blue_1);
    bind_insert_stmt 6 (Data.INT match_schudle_record.blue_2);
    bind_insert_stmt 7 (Data.INT match_schudle_record.blue_3);

    match step insert_stmt with
    | Rc.DONE ->
        let row_id = Sqlite3.last_insert_rowid db in
        print_endline
          ("Successfully added record... Row ID: " ^ Int64.to_string row_id)
    | r ->
        prerr_endline (Rc.to_string r);
        prerr_endline (errmsg db)

  (* getting data functions *)
  let get_team_for_match_and_position db match_number position =
    let open DB_operation_utils in
    let sql =
      Printf.sprintf "SELECT %s FROM %s WHERE match_number=%d"
        (robot_position_to_string position)
        table_name match_number
    in

    let result = get_int_result_list_for_query db sql in

    match result with Some (t :: []) -> Some t | _ -> None
end

module Robot_pictures = struct
  let table_name = "robot_pictures"

  type robot_picture_record = {
    team_number : int;
    image : string 
  }

  let create_table db =
    let sql =
      "CREATE TABLE " ^ table_name ^ "(team_number INT PRIMARY KEY, image BLOB)"
    in

    DB_operation_utils.create_table_helper db sql table_name


  let insert_robot_picture_record db record = 
    let open Sqlite3 in
    let sql = "INSERT INTO " ^ table_name ^ " VALUES(?,?)" in
    let insert_stmt = prepare db sql in

    let bind_insert_stmt =
      DB_operation_utils.bind_insert_statement insert_stmt db
    in

    bind_insert_stmt 1 (Data.INT (Int64.of_int record.team_number));
    bind_insert_stmt 2 (Data.BLOB record.image);
    

    match step insert_stmt with
    | Rc.DONE ->
        let row_id = Sqlite3.last_insert_rowid db in
        print_endline
          ("Successfully added record... Row ID: " ^ Int64.to_string row_id)
    | r ->
        prerr_endline (Rc.to_string r);
        prerr_endline (errmsg db)

  let get_robot_picture db team_number =
     let sql =
       Printf.sprintf "SELECT image FROM %s WHERE team_number=%d" table_name
         team_number
     in

     let result = DB_operation_utils.get_blob_or_text_result_list_for_query db sql in
     
     match result with 
     | Some (t :: []) -> Some t
     | _ -> None
end


open Sqlite3

let db = db_open "test.db"

let sample_data : Raw_match_data_table.raw_match_data_table_record =
  {
    team_number = 2930L;
    team_name = "sonic_squirrels";
    match_number = 5L;
    scouter_name = "Keyush(2930)";
    auto_mobility = true;
    auto_climb = Engaged;
    auto_cone_high = 1L;
    auto_cone_mid = 1L;
    auto_cone_low = 1L;
    auto_cube_high = 1L;
    auto_cube_mid = 1L;
    auto_cube_low = 1L;
    (* tele *)
    tele_climb = Engaged;
    tele_cone_high = 4L;
    tele_cone_mid = 4L;
    tele_cone_low = 4L;
    tele_cube_high = 4L;
    tele_cube_mid = 4L;
    tele_cube_low = 4L;
    (* misc *)
    incap = false;
    playing_defense = false;
    notes = "fast cycler";
  }

let sql = "SELECT * FROM raw_match_data WHERE rowid=3"

let print_to_console_cb row headers =
  let n = Array.length row - 1 in
  let () =
    for i = 0 to n do
      let value = match row.(i) with Some s -> s | None -> "Null" in
      Printf.printf "| %s: %s |" headers.(i) value
    done
  in
  print_endline ""

(* let get_whole_table cb =
   let sql = "SELECT * FROM " ^ table_name in
   match exec db ~cb sql with
   | Rc.OK -> print_endline "successfully accessed whole table"
   | r -> formatted_error_message r "failed to get whole table" *)

(* let execute_select_sql cb sql =
   match exec db ~cb sql with
   | Rc.OK -> print_endline ("successfully executed SQL STATEMENT || " ^ sql ^ " ||")
   | r -> formatted_error_message r ("failed sql || " ^ sql ^ " ||") *)

(* let create_table =
   let sql = get_create_table_sql table_colums_arr in *)

(* match exec db sql with
   | Rc.OK -> print_endline "CREATED TABLE"
   | _ -> print_endline ("--- TABLE ALREADY EXISTS --- continuing forward with program") *)

(* let accept_qr_code_data json : string    *)

(*
   let () = create_table;
     insert_db_record sample_data;
     execute_select_sql print_to_console_cb ("SELECT team_number, team_name, match FROM " ^ table_name ^ " WHERE notes='fast cycler'")
*)

(* let () = Raw_match_data_table.insert_db_record sample_data db; Raw_match_data_table.insert_db_record sample_data db; Raw_match_data_table.insert_db_record sample_data db *)

(* let () = Match_schudle_table.create_table db  *)

(* Raw_match_data_table.insert_db_record sample_data db   *)

(* let () = Match_schudle_table.create_table db  *)

(* QR CODE CODEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE *)

(* let long_string =
     let len = 2953 in
     let buffer = Buffer.create len in

     for _i = 0 to len-1 do
       Buffer.add_string buffer "{"
     done;

     Buffer.contents buffer

   let () =
     let m = long_string in
     let x = Qrc.encode ~ec_level:`L m in
     match x with
     | Some s ->
       let oc = open_out "image.svg"in
       let svg = Qrc.Matrix.to_svg s in
       Printf.fprintf oc "%s\n" svg;
       close_out oc
     | None -> print_endline "FAILED" *)

(* TODO: https://ocaml.org/p/vector/latest/doc/Vector/index.html *)

(* let () =
   let x = Match_schudle_table.get_team_for_match_and_position db 4 Blue_3 in
   match x with
   | Some y -> print_endline ("TEAM NUMBER " ^ string_of_int y)
   | None -> print_endline("NO RESULT") *)
