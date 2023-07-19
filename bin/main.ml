

type climb = No_climb | Docked | Engaged

let climb_to_string = function
  | No_climb -> "NONE"
  | Docked -> "DOCKED"
  | Engaged -> "Engaged"

type db_record = {
  (* team *)
  team_number : int64; 
  team_name : string;
  match_number : int64;
  (* scouter name *)

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

let table_colums_arr = [| 
  ("team_number INT"); 
  ("team_name TEXT");
  ("match INT");

  (* auto *)
  ("auto_moblity INT");
  ("auto_climb TEXT");

  ("auto_cone_high INT");
  ("auto_cone_mid INT");
  ("auto_cone_low INT");

  ("auto_cube_high INT");
  ("auto_cube_mid INT");
  ("auto_cube_low INT");

  (* tele *)
  ("tele_climb TEXT");

  ("tele_cone_high INT");
  ("ele_cone_mid INT");
  ("tele_cone_low INT");
  
  ("tele_cube_high INT");
  ("tele_cube_mid INT");
  ("tele_cube_low INT");

  (* mics *)
  ("incap INT");
  ("playing_defense INT");
  ("notes TEXT");


  |]

let table_name = "raw_match_data"

let get_create_table_sql arr = 
  let initial_sql = "CREATE TABLE " ^ table_name ^ "(" in 

  let rec table_colums_as_string_list i list = 
    if i == (Array.length arr) then list else 
    let new_list = List.append list [(arr.(i))] in 
    table_colums_as_string_list (i+1) new_list 
  in 

  let colum_list = table_colums_as_string_list 0 [] in 

initial_sql ^ (String.concat "," colum_list) ^ ")"  








  
  



open Sqlite3

let db = db_open "test.db"




let int64_of_bool = function false -> 0L | true -> 1L





let formatted_error_message error message =
  prerr_endline ( "**ERROR** \n *error code: " ^ (Sqlite3.Rc.to_string error) ^ "\n *last db error message: "^ (Sqlite3.errmsg db) ^ "\n *debug message: " ^ message ^ "\n")



(* upsert *)
(* return primary key option None or primary key *)
let insert_db_record data = 
  let insert_sql =
    "INSERT INTO " ^ table_name
    ^ " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)" in 

  let insert_stmt = prepare db insert_sql in 

  let bind_insert_stmt pos data = 
    let result = bind insert_stmt pos data in
    match result with
    | Rc.OK -> ()
    | r ->
        prerr_endline (Rc.to_string r);
        prerr_endline (errmsg db) 
    in 

  bind_insert_stmt 1 (Data.INT data.team_number);
  bind_insert_stmt 2 (Data.TEXT data.team_name);
  bind_insert_stmt 3 (Data.INT data.match_number);


  (* auto *)
  bind_insert_stmt 4 (Data.INT (int64_of_bool data.auto_mobility));
  bind_insert_stmt 5 (Data.TEXT (climb_to_string data.auto_climb));

  bind_insert_stmt 6 (Data.INT data.auto_cone_high);
  bind_insert_stmt 7 (Data.INT data.auto_cone_mid);
  bind_insert_stmt 8 (Data.INT data.auto_cone_low);

  bind_insert_stmt 9 (Data.INT data.auto_cube_high);
  bind_insert_stmt 10 (Data.INT data.auto_cube_mid);
  bind_insert_stmt 11 (Data.INT data.auto_cube_low);


  (* tele *)
  bind_insert_stmt 12 (Data.TEXT (climb_to_string data.tele_climb));

  bind_insert_stmt 13 (Data.INT data.tele_cone_high);
  bind_insert_stmt 14 (Data.INT data.tele_cone_mid);
  bind_insert_stmt 15 (Data.INT data.tele_cone_low);

  bind_insert_stmt 16 (Data.INT data.tele_cube_high);
  bind_insert_stmt 17 (Data.INT data.tele_cube_mid);
  bind_insert_stmt 18 (Data.INT data.tele_cube_low);


  (* misc *)
  bind_insert_stmt 19 (Data.INT (int64_of_bool data.incap));
  bind_insert_stmt 20 (Data.INT (int64_of_bool data.playing_defense));
  bind_insert_stmt 21 (Data.TEXT data.notes);
  
  match step insert_stmt with 
    | Rc.DONE -> 
      let row_id = Sqlite3.last_insert_rowid db in 
      print_endline ("Successfully added record... Row ID: " ^ (Int64.to_string row_id)) 
    | r -> prerr_endline ("first prind" ^ (Rc.to_string r)); prerr_endline ("second print" ^ (errmsg db))






  let sample_data : db_record =
  {
    team_number = 2930L;
    team_name = "sonic_squirrels";
    match_number = 5L;

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



let get_whole_table cb = 
  let sql = "SELECT * FROM " ^ table_name in 
  match exec db ~cb sql with 
  | Rc.OK -> print_endline "successfully accessed whole table"
  | r -> formatted_error_message r "failed to get whole table"

let execute_select_sql cb sql = 
  match exec db ~cb sql with 
  | Rc.OK -> print_endline ("successfully executed SQL STATEMENT || " ^ sql ^ " ||") 
  | r -> formatted_error_message r ("failed sql || " ^ sql ^ " ||")


let create_table = 
  let sql = get_create_table_sql table_colums_arr in 

  match exec db sql with 
  | Rc.OK -> print_endline "CREATED TABLE"
  | _ -> print_endline ("--- TABLE ALREADY EXISTS --- continuing forward with program")


(* let accept_qr_code_data json : string    *)






let () = create_table; 
  insert_db_record sample_data;
  execute_select_sql print_to_console_cb ("SELECT team_number, team_name, match FROM " ^ table_name ^ " WHERE notes='fast cycler'")



