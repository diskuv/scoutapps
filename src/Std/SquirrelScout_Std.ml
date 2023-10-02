include SquirrelScout_Std_intf

(* module Match_schedule_table = Match_schedule_table  *)

let create_all_tables db =
  match Raw_match_data_table.Table.create_table db with
  | Db_utils.Failed ->
    Logs.err (fun l -> l "Could not create raw match table");
    Db_utils.Failed
  | _ ->
  match Match_schedule_table.Table.create_table db with
  | Db_utils.Failed ->
    Logs.err (fun l -> l "Could not create match schedule table");
    Db_utils.Failed
  | _ ->
  match Robot_pictures_table.Table.create_table db with
  | Db_utils.Failed ->
    Logs.err (fun l -> l "Could not create robot pictures table");
    Db_utils.Failed
  | _ ->
  match Team_names_table.Table.create_table db with
  | Db_utils.Failed ->
    Logs.err (fun l -> l "Could not create team names table");
    Db_utils.Failed
  | _ -> Db_utils.Successful

let test_function db_name () =
  let db = Sqlite3.db_open db_name in
  let _ = Raw_match_data_table.Table.create_table db in

  print_endline ""

let create_capnp_string ~team_number ~team_name ~match_number mobility auto_cone
    auto_cube tele_cone tele_cube =
  let module Schema = Schema.Make (Capnp.BytesMessage) in
  let rw = Schema.Builder.RawMatchData.init_root () in

  let open Schema.Builder.RawMatchData in
  team_number_set_exn rw team_number;
  team_name_set rw team_name;
  match_number_set_exn rw match_number;

  auto_mobility_set rw mobility;

  auto_cone_high_set_exn rw auto_cone;
  auto_cube_high_set_exn rw auto_cube;

  tele_cone_high_set_exn rw tele_cone;
  tele_cube_high_set_exn rw tele_cube;

  scouter_name_set rw "admin";

  notes_set rw "no notes";

  let message = to_message rw in

  Capnp.Codecs.serialize ~compression:`None message

let fill_raw_match_data_table db =
  let default_nums = create_capnp_string true 9 8 2 1 in
  let l =
    [
      default_nums ~team_number:5941 ~team_name:"name" ~match_number:1;
      default_nums ~team_number:3268 ~team_name:"name" ~match_number:1;
      default_nums ~team_number:2910 ~team_name:"name" ~match_number:1;
      default_nums ~team_number:4089 ~team_name:"name" ~match_number:1;
      default_nums ~team_number:4915 ~team_name:"name" ~match_number:1;
      default_nums ~team_number:4682 ~team_name:"name" ~match_number:1;
      default_nums ~team_number:5588 ~team_name:"name" ~match_number:2;
      default_nums ~team_number:1899 ~team_name:"name" ~match_number:2;
      default_nums ~team_number:2412 ~team_name:"name" ~match_number:2;
      default_nums ~team_number:9036 ~team_name:"name" ~match_number:2;
      default_nums ~team_number:3049 ~team_name:"name" ~match_number:2;
      (* MISSING: 3826 BLUE3 *)
      default_nums ~team_number:4980 ~team_name:"name" ~match_number:3;
      default_nums ~team_number:949 ~team_name:"name" ~match_number:3;
      default_nums ~team_number:1778 ~team_name:"name" ~match_number:3;
      (* missing: 8248	2980	1318 blue alliance *)
    ]
  in

  List.iter
    (fun a ->
      let _ = Raw_match_data_table.Table.insert_record db a in
      ())
    l

let pose_to_string pos = Match_schedule_table.Table.robot_position_to_string pos

module type Db_holder = sig
  type t = Sqlite3.db 

  val db : t 

end

module Database_actions (Db : Db_holder) = struct

  let get_latest_match () =
    Raw_match_data_table.Table.Fetch.latest_match_number Db.db 

  let get_matches_for_team team =
    Match_schedule_table.Table.Fetch.get_all_matches_for_team Db.db team

  let get_whole_schedule () =
    Match_schedule_table.Table.Fetch.get_whole_schedule Db.db

  let get_missing_records_from_db () =
    Raw_match_data_table.Table.Fetch.missing_data Db.db


    (* Position referes to type robot_position in Match_schedule_table *)
    (* for java  *)
  let get_team_for_match_and_position team_number position = 
    Match_schedule_table.Table.Fetch.get_team_for_match_and_position Db.db team_number position 

(* for java  *)
  let insert_scouted_data blob = 
    Raw_match_data_table.Table.insert_record Db.db blob 


  let initialize () = 
      match create_all_tables Db.db with
      | Db_utils.Failed ->
        failwith "Failed to initialize the SquirrelScout database"
      | Successful -> ()

  let insert_match_json ~json_contents () =
    match Match_schedule_table.Table.fill_database_from_json Db.db json_contents with
    | Db_utils.Failed ->
      Logs.err (fun l -> l "Could not fill match schedule table with JSON data")
    | Successful ->
    match Team_names_table.Table.insert_record Db.db json_contents with
    | Db_utils.Failed ->
      Logs.err (fun l -> l "Could not fill team names table with JSON data")
    | Successful -> ()

  let insert_raw_match_test_data () =
    fill_raw_match_data_table Db.db

end

let create_object ~db_path () = 
  let db = Sqlite3.db_open db_path in 

  let module Fetchable_data = Database_actions (struct
    type t = Sqlite3.db 

    let db = db 
  end) in   

  Fetchable_data.initialize ();

  (module Fetchable_data : Database_actions_type) 

(* for java *)
let generate_qr_code blob = 
  Qr_manager.generate_qr_code blob 

module For_testing = struct
  let create_all_tables = create_all_tables

  let return_code_to_string = Db_utils.return_code_to_string
end
