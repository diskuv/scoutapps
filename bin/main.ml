[@@@ocaml.warning "-32-37"]

(* module Foo = Foo.Make Capnp.BytesMessage *)


(* module Foo = Foo.Make( Capnp.BytesMessage ) *)

(* module Foo = Foo.Make(Capnp.BytesMessage) *)
(* 
module Foo = Foo.Make(Capnp.BytesMessage)

let encode =  

  let rw = Foo.Builder.Person.init_root () in 

  Foo.Builder.Person.num_set_exn rw 31;

  let message = Foo.Builder.Person.to_message rw in 

  Capnp.Codecs.serialize ~compression:`None message *)








(* let db = Sqlite3.db_open "test.db" *)

module DB_operation_utils = struct
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
    team_number : int;
    team_name : string;
    match_number : int;
    scouter_name : string;
    (* auto *)
    auto_mobility : bool;
    auto_climb : climb;
    auto_cone_high : int;
    auto_cone_mid : int;
    auto_cone_low : int;
    auto_cube_high : int;
    auto_cube_mid : int;
    auto_cube_low : int;
    (* tele *)
    tele_climb : climb;
    tele_cone_high : int;
    tele_cone_mid : int;
    tele_cone_low : int;
    tele_cube_high : int;
    tele_cube_mid : int;
    tele_cube_low : int;
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

    DB_operation_utils.create_table_helper db finilazed_sql table_name

  (* upsert *)
  (* return primary key option None or primary key *)
  let insert_db_record db data =
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

    bind_insert_stmt 1 (Data.INT (Int64.of_int data.team_number));
    bind_insert_stmt 2 (Data.TEXT data.team_name);
    bind_insert_stmt 3 (Data.INT (Int64.of_int data.match_number));
    bind_insert_stmt 4 (Data.TEXT data.scouter_name);

    (* auto *)
    bind_insert_stmt 5 (Data.INT (int64_of_bool data.auto_mobility));
    bind_insert_stmt 6 (Data.TEXT (climb_to_string data.auto_climb));

    bind_insert_stmt 7 (Data.INT (Int64.of_int data.auto_cone_high));
    bind_insert_stmt 8 (Data.INT (Int64.of_int data.auto_cone_mid));
    bind_insert_stmt 9 (Data.INT (Int64.of_int data.auto_cone_low));

    bind_insert_stmt 10 (Data.INT (Int64.of_int data.auto_cube_high));
    bind_insert_stmt 11 (Data.INT (Int64.of_int data.auto_cube_mid));
    bind_insert_stmt 12 (Data.INT (Int64.of_int data.auto_cube_low));

    (* tele *)
    bind_insert_stmt 13 (Data.TEXT (climb_to_string data.tele_climb));

    bind_insert_stmt 14 (Data.INT (Int64.of_int data.tele_cone_high));
    bind_insert_stmt 15 (Data.INT (Int64.of_int data.tele_cone_mid));
    bind_insert_stmt 16 (Data.INT (Int64.of_int data.tele_cone_low));

    bind_insert_stmt 17 (Data.INT (Int64.of_int data.tele_cube_high));
    bind_insert_stmt 18 (Data.INT (Int64.of_int data.tele_cube_mid));
    bind_insert_stmt 19 (Data.INT (Int64.of_int data.tele_cube_low));

    (* misc *)
    bind_insert_stmt 20 (Data.INT (int64_of_bool data.incap));
    bind_insert_stmt 21 (Data.INT (int64_of_bool data.playing_defense));
    bind_insert_stmt 22 (Data.TEXT data.notes);

    match step insert_stmt with
    | Rc.DONE ->
        let row_id = Sqlite3.last_insert_rowid db in
        Printf.printf
          "SUCCESSFULLY INSERTED RECORD INTO: \n\
          \          *TABLE=%S \n\
          \          *row_id=%d\n\
          \          *team_number=%d \n\
          \          *match_number=%d \n\
          \          *scouter_name=%s \n" table_name (Int64.to_int row_id)
          data.team_number data.match_number data.scouter_name;

        Some (data.team_number, data.match_number, data.scouter_name)
    | r ->
        DB_operation_utils.formatted_error_message db r
          ("Failed to insert record into " ^ table_name);
        None

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
    match_number : int;
    red_1 : int;
    red_2 : int;
    red_3 : int;
    blue_1 : int;
    blue_2 : int;
    blue_3 : int;
  } [@@deriving yojson]

  type json_input_data = {
    records : match_schudle_record list
  } [@@deriving yojson]

  let create_table db =
    let sql =
      "CREATE TABLE " ^ table_name
      ^ "(match_number INT PRIMARY KEY, red_1 INT, red_2 INT, red_3 INT, blue_1 INT, \
         blue_2 INT, blue_3 INT)"
    in

    DB_operation_utils.create_table_helper db sql table_name

  let insert_match_schudle_record db match_schudle_record =
    let open Sqlite3 in
    let sql = "INSERT INTO " ^ table_name ^ " VALUES(?,?,?,?,?,?,?)" in
    let insert_stmt = prepare db sql in

    let bind_insert_stmt =
      DB_operation_utils.bind_insert_statement insert_stmt db
    in

    bind_insert_stmt 1
      (Data.INT (Int64.of_int match_schudle_record.match_number));

    bind_insert_stmt 2 (Data.INT (Int64.of_int match_schudle_record.red_1));
    bind_insert_stmt 3 (Data.INT (Int64.of_int match_schudle_record.red_2));
    bind_insert_stmt 4 (Data.INT (Int64.of_int match_schudle_record.red_3));

    bind_insert_stmt 5 (Data.INT (Int64.of_int match_schudle_record.blue_1));
    bind_insert_stmt 6 (Data.INT (Int64.of_int match_schudle_record.blue_2));
    bind_insert_stmt 7 (Data.INT (Int64.of_int match_schudle_record.blue_3));

    match step insert_stmt with
    | Rc.DONE ->
        let row_id = Sqlite3.last_insert_rowid db in
        Printf.printf
          "SUCCESSFULLY INSERTED RECORD INTO: \n\
          \          *TABLE=%S \n\
          \          *row_id=%d\n\
          \          *match_number=%d \n "
          table_name (Int64.to_int row_id) match_schudle_record.match_number;

        Some match_schudle_record.match_number
    | r ->
        DB_operation_utils.formatted_error_message db r ("failed to insert record into " ^ table_name);
        None


  (* getting data functions *)
  let get_team_for_match_and_position db match_number position =
    let open DB_operation_utils in
    let sql =
      Printf.sprintf "SELECT %s FROM %s WHERE match_number=%d"
        (robot_position_to_string position)
        table_name 
        match_number
    in

    let result = get_int_result_list_for_query db sql in

    match result with Some (t :: []) -> Some t | _ -> None


  let load_database_from_json db data = 
    let native_record = json_input_data_of_yojson (Yojson.Safe.from_string data) in 

    let records = match native_record with
    | Result.Ok s -> s 
    | Result.Error r -> failwith ("failed: " ^ r) in 

    List.iter (fun a ->  match insert_match_schudle_record db a with | Some _ -> print_endline "yes" | None -> print_endline "no"  ) records.records




end

module Robot_pictures = struct
  let table_name = "robot_pictures_table"

  type robot_picture_record = { team_number : int; image : string }

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
        Printf.printf "SUCCESSFULLY INSERTED RECORD INTO: \n\
          \          *TABLE=%S \n\
          \          *row_id=%d\n\
          \          *team_number=%d \n " 
          table_name (Int64.to_int row_id) record.team_number;
        
        Some record.team_number  
    | r ->
        DB_operation_utils.formatted_error_message db r ("failed to insert record into " ^ table_name);
        None

  let get_robot_picture db team_number =
    let sql =
      Printf.sprintf "SELECT image FROM %s WHERE team_number=%d" table_name
        team_number
    in

    let result =
      DB_operation_utils.get_blob_or_text_result_list_for_query db sql
    in

    match result with Some (t :: []) -> Some t | _ -> None
end
















let sample_scouted_data : Raw_match_data_table.raw_match_data_table_record =
  {
    team_number = 2930;
    team_name = "sonic_squirrels";
    match_number = 5;
    scouter_name = "Keyush(2930)";
    auto_mobility = true;
    auto_climb = Engaged;
    auto_cone_high = 1;
    auto_cone_mid = 1;
    auto_cone_low = 1;
    auto_cube_high = 1;
    auto_cube_mid = 1;
    auto_cube_low = 1;
    (* tele *)
    tele_climb = Engaged;
    tele_cone_high = 4;
    tele_cone_mid = 4;
    tele_cone_low = 4;
    tele_cube_high = 4;
    tele_cube_mid = 4;
    tele_cube_low = 4;
    (* misc *)
    incap = false;
    playing_defense = false;
    notes = "fast cycler";
  }

let sample_match_schudle_data : Match_schudle_table.match_schudle_record =
  {
    match_number = 1;
    red_1 = 2930;
    red_2 = 2910;
    red_3 = 254;
    blue_1 = 1678;
    blue_2 = 2056;
    blue_3 = 118;
  }

let sample_robot_image_data : Robot_pictures.robot_picture_record =
  { team_number = 2930; image = "dsadsadwasdhawdhsakdhqwiyd" }

let print_to_console_cb row headers =
  let n = Array.length row - 1 in
  let () =
    for i = 0 to n do
      let value = match row.(i) with Some s -> s | None -> "Null" in
      Printf.printf "| %s: %s |" headers.(i) value
    done
  in
  print_endline ""

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

let create_all_tables db =     
  Raw_match_data_table.create_table db;
  Match_schudle_table.create_table db ;
  Robot_pictures.create_table db

(* let test_insert_records =
  let _ = Raw_match_data_table.insert_db_record sample_scouted_data in
  let _ = Match_schudle_table.insert_match_schudle_record sample_match_schudle_data in 
  let _ = Robot_pictures.insert_robot_picture_record sample_robot_image_data in 
  ()  *)




  (* let () = 
  Match_schudle_table.create_table;

  let str = Core.In_channel.read_all "./match_schedule.json" in 
  Match_schudle_table.load_database_from_json str *)

(* 
  let () = 
    let command = "aws sqs send-message --queue-url https://sqs.us-east-1.amazonaws.com/992642541356/test_queue --message-body " ^ encode in 
    let _ = Sys.command command  in 
    print_endline "done" *)



  (* test_insert_records; *)


  

let () =
  let db = Sqlite3.db_open "test.db" in 
  create_all_tables db

  (* let () = 
    let str = encode in 
    let by = Bytes.of_string str in 

    for i = 0 to Bytes.length by do 
      let b = Bytes.get by 1 in 
      print_endline ("i: " ^ (string_of_int i) ^ "|| char: " ^ ( String.make 1 b)) 
    done  *)
    

    

