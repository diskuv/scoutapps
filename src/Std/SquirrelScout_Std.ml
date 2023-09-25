(** Adapted from: https://github.com/dkim/rwo-lwt *)

let sample_json =
{|{"records": [{"match_number": 1, "red_1": 5941, "red_2": 3268, "red_3": 2910, "blue_1": 4089, "blue_2": 4915, "blue_3": 4682}, {"match_number": 10, "red_1": 4089, "red_2": 4911, "red_3": 949, "blue_1": 3681, "blue_2": 2928, "blue_3": 6350}, {"match_number": 11, "red_1": 4512, "red_2": 2903, "red_3": 5588, "blue_1": 2412, "blue_2": 7627, "blue_3": 2147}, {"match_number": 12, "red_1": 4980, "red_2": 9036, "red_3": 4682, "blue_1": 4131, "blue_2": 4173, "blue_3": 488}, {"match_number": 13, "red_1": 2976, "red_2": 4911, "red_3": 2910, "blue_1": 3681, "blue_2": 1318, "blue_3": 3049}, {"match_number": 14, "red_1": 2930, "red_2": 2522, "red_3": 8248, "blue_1": 4512, "blue_2": 4089, "blue_3": 2928}, {"match_number": 15, "red_1": 5941, "red_2": 7627, "red_3": 2980, "blue_1": 1899, "blue_2": 3826, "blue_3": 4682}, {"match_number": 16, "red_1": 2147, "red_2": 4915, "red_3": 2903, "blue_1": 3268, "blue_2": 2412, "blue_3": 6350}, {"match_number": 17, "red_1": 1778, "red_2": 2097, "red_3": 5588, "blue_1": 4681, "blue_2": 949, "blue_3": 4173}, {"match_number": 18, "red_1": 2910, "red_2": 7627, "red_3": 4980, "blue_1": 2980, "blue_2": 4131, "blue_3": 2976}, {"match_number": 19, "red_1": 2522, "red_2": 4682, "red_3": 2412, "blue_1": 3268, "blue_2": 4911, "blue_3": 2930}, {"match_number": 2, "red_1": 5588, "red_2": 1899, "red_3": 2412, "blue_1": 9036, "blue_2": 3049, "blue_3": 3826}, {"match_number": 20, "red_1": 4512, "red_2": 3681, "red_3": 9036, "blue_1": 4915, "blue_2": 1318, "blue_3": 949}, {"match_number": 21, "red_1": 488, "red_2": 8248, "red_3": 2928, "blue_1": 2903, "blue_2": 1899, "blue_3": 2097}, {"match_number": 22, "red_1": 3049, "red_2": 2147, "red_3": 4173, "blue_1": 3826, "blue_2": 5588, "blue_3": 4089}, {"match_number": 23, "red_1": 4681, "red_2": 5941, "red_3": 2930, "blue_1": 6350, "blue_2": 1778, "blue_3": 2980}, {"match_number": 24, "red_1": 2928, "red_2": 4980, "red_3": 2412, "blue_1": 488, "blue_2": 2910, "blue_3": 2903}, {"match_number": 25, "red_1": 1318, "red_2": 2522, "red_3": 4512, "blue_1": 3826, "blue_2": 4131, "blue_3": 7627}, {"match_number": 26, "red_1": 3049, "red_2": 4089, "red_3": 3268, "blue_1": 5588, "blue_2": 4681, "blue_3": 2147}, {"match_number": 27, "red_1": 4173, "red_2": 3681, "red_3": 4915, "blue_1": 9036, "blue_2": 1778, "blue_3": 8248}, {"match_number": 28, "red_1": 2976, "red_2": 6350, "red_3": 2097, "blue_1": 4682, "blue_2": 4911, "blue_3": 5941}, {"match_number": 29, "red_1": 949, "red_2": 4131, "red_3": 3268, "blue_1": 1899, "blue_2": 2930, "blue_3": 4980}, {"match_number": 3, "red_1": 4980, "red_2": 949, "red_3": 1778, "blue_1": 8248, "blue_2": 2980, "blue_3": 1318}, {"match_number": 30, "red_1": 2147, "red_2": 9036, "red_3": 2522, "blue_1": 1778, "blue_2": 4089, "blue_3": 7627}, {"match_number": 31, "red_1": 4911, "red_2": 2412, "red_3": 488, "blue_1": 8248, "blue_2": 4512, "blue_3": 5941}, {"match_number": 32, "red_1": 2980, "red_2": 1899, "red_3": 3681, "blue_1": 1318, "blue_2": 5588, "blue_3": 6350}, {"match_number": 33, "red_1": 949, "red_2": 4682, "red_3": 2097, "blue_1": 2910, "blue_2": 4915, "blue_3": 3049}, {"match_number": 34, "red_1": 4173, "red_2": 3826, "red_3": 2976, "blue_1": 2928, "blue_2": 2903, "blue_3": 4681}, {"match_number": 35, "red_1": 4911, "red_2": 1778, "red_3": 1899, "blue_1": 3268, "blue_2": 488, "blue_3": 2522}, {"match_number": 36, "red_1": 6350, "red_2": 2147, "red_3": 4089, "blue_1": 4131, "blue_2": 2097, "blue_3": 4512}, {"match_number": 37, "red_1": 5588, "red_2": 8248, "red_3": 3681, "blue_1": 2930, "blue_2": 2910, "blue_3": 9036}, {"match_number": 38, "red_1": 2903, "red_2": 5941, "red_3": 2976, "blue_1": 3049, "blue_2": 2980, "blue_3": 949}, {"match_number": 39, "red_1": 4682, "red_2": 2928, "red_3": 4173, "blue_1": 2412, "blue_2": 1318, "blue_3": 4681}, {"match_number": 4, "red_1": 2903, "red_2": 2930, "red_3": 4131, "blue_1": 4681, "blue_2": 2097, "blue_3": 4911}, {"match_number": 40, "red_1": 3826, "red_2": 2930, "red_3": 7627, "blue_1": 4915, "blue_2": 4980, "blue_3": 4911}, {"match_number": 41, "red_1": 8248, "red_2": 6350, "red_3": 3049, "blue_1": 2097, "blue_2": 2522, "blue_3": 2910}, {"match_number": 42, "red_1": 4089, "red_2": 1899, "red_3": 1318, "blue_1": 1778, "blue_2": 5941, "blue_3": 2412}, {"match_number": 43, "red_1": 4512, "red_2": 7627, "red_3": 4915, "blue_1": 2980, "blue_2": 5588, "blue_3": 4173}, {"match_number": 44, "red_1": 4980, "red_2": 2147, "red_3": 3268, "blue_1": 9036, "blue_2": 2976, "blue_3": 2928}, {"match_number": 45, "red_1": 4681, "red_2": 4131, "red_3": 4682, "blue_1": 949, "blue_2": 3681, "blue_3": 2903}, {"match_number": 46, "red_1": 2910, "red_2": 3826, "red_3": 1318, "blue_1": 488, "blue_2": 2097, "blue_3": 4089}, {"match_number": 47, "red_1": 5941, "red_2": 5588, "red_3": 9036, "blue_1": 4911, "blue_2": 4173, "blue_3": 4512}, {"match_number": 48, "red_1": 2930, "red_2": 1778, "red_3": 4915, "blue_1": 4131, "blue_2": 2928, "blue_3": 2147}, {"match_number": 49, "red_1": 2903, "red_2": 2412, "red_3": 3049, "blue_1": 2522, "blue_2": 4980, "blue_3": 3681}, {"match_number": 5, "red_1": 3681, "red_2": 2976, "red_3": 488, "blue_1": 4173, "blue_2": 2522, "blue_3": 6350}, {"match_number": 50, "red_1": 6350, "red_2": 949, "red_3": 3826, "blue_1": 4682, "blue_2": 3268, "blue_3": 2980}, {"match_number": 51, "red_1": 1899, "red_2": 4681, "red_3": 488, "blue_1": 7627, "blue_2": 2976, "blue_3": 8248}, {"match_number": 52, "red_1": 4911, "red_2": 3049, "red_3": 4131, "blue_1": 2412, "blue_2": 2910, "blue_3": 3681}, {"match_number": 53, "red_1": 5941, "red_2": 4089, "red_3": 2522, "blue_1": 2928, "blue_2": 2930, "blue_3": 5588}, {"match_number": 54, "red_1": 1318, "red_2": 4173, "red_3": 2097, "blue_1": 8248, "blue_2": 3268, "blue_3": 1899}, {"match_number": 55, "red_1": 949, "red_2": 488, "red_3": 7627, "blue_1": 6350, "blue_2": 4681, "blue_3": 4915}, {"match_number": 56, "red_1": 1778, "red_2": 4512, "red_3": 2976, "blue_1": 3826, "blue_2": 2903, "blue_3": 4980}, {"match_number": 57, "red_1": 9036, "red_2": 2980, "red_3": 4911, "blue_1": 2147, "blue_2": 4682, "blue_3": 8248}, {"match_number": 58, "red_1": 4915, "red_2": 3268, "red_3": 2928, "blue_1": 7627, "blue_2": 3049, "blue_3": 2522}, {"match_number": 59, "red_1": 2910, "red_2": 4681, "red_3": 1778, "blue_1": 1899, "blue_2": 4512, "blue_3": 949}, {"match_number": 6, "red_1": 7627, "red_2": 2928, "red_3": 1899, "blue_1": 2147, "blue_2": 4512, "blue_3": 2910}, {"match_number": 60, "red_1": 4682, "red_2": 6350, "red_3": 2903, "blue_1": 1318, "blue_2": 9036, "blue_3": 4131}, {"match_number": 61, "red_1": 3681, "red_2": 2147, "red_3": 3826, "blue_1": 2097, "blue_2": 4980, "blue_3": 5941}, {"match_number": 62, "red_1": 2930, "red_2": 488, "red_3": 2980, "blue_1": 2412, "blue_2": 4173, "blue_3": 4089}, {"match_number": 63, "red_1": 5588, "red_2": 4915, "red_3": 4131, "blue_1": 2976, "blue_2": 4682, "blue_3": 1318}, {"match_number": 64, "red_1": 2928, "red_2": 3049, "red_3": 5941, "blue_1": 7627, "blue_2": 6350, "blue_3": 9036}, {"match_number": 65, "red_1": 4173, "red_2": 2910, "red_3": 1899, "blue_1": 2522, "blue_2": 2903, "blue_3": 4911}, {"match_number": 66, "red_1": 4089, "red_2": 8248, "red_3": 4681, "blue_1": 4980, "blue_2": 488, "blue_3": 5588}, {"match_number": 67, "red_1": 2097, "red_2": 2412, "red_3": 2930, "blue_1": 2976, "blue_2": 949, "blue_3": 2147}, {"match_number": 68, "red_1": 2980, "red_2": 3826, "red_3": 4512, "blue_1": 3268, "blue_2": 3681, "blue_3": 1778}, {"match_number": 7, "red_1": 4131, "red_2": 8248, "red_3": 4980, "blue_1": 4915, "blue_2": 5941, "blue_3": 3826}, {"match_number": 8, "red_1": 488, "red_2": 1318, "red_3": 1778, "blue_1": 3049, "blue_2": 2976, "blue_3": 2930}, {"match_number": 9, "red_1": 2522, "red_2": 2980, "red_3": 4681, "blue_1": 2097, "blue_2": 9036, "blue_3": 3268}], "names": [{"number": 1318, "name": "Issaquah Robotics Society"}, {"number": 1778, "name": "Chill Out"}, {"number": 1899, "name": "Saints Robotics"}, {"number": 2097, "name": "Phoenix Force Robotics"}, {"number": 2147, "name": "CHUCK"}, {"number": 2412, "name": "Robototes"}, {"number": 2522, "name": "Royal Robotics"}, {"number": 2903, "name": "NeoBots"}, {"number": 2910, "name": "Jack in the Bot"}, {"number": 2928, "name": "Viking Robotics"}, {"number": 2930, "name": "Sonic Squirrels"}, {"number": 2976, "name": "The Spartabots"}, {"number": 2980, "name": "Whidbey Island Wildcats"}, {"number": 3049, "name": "BremerTron"}, {"number": 3268, "name": "Vahallabots"}, {"number": 3681, "name": "Robo-Raiders"}, {"number": 3826, "name": "Sequim Robotics Federation SRF"}, {"number": 4089, "name": "Stealth Robotics"}, {"number": 4131, "name": "Iron Patriots"}, {"number": 4173, "name": "IMVERT (Mount Vernon Robotics Team)"}, {"number": 4512, "name": "Otter Chaos"}, {"number": 4681, "name": "Murphy's law"}, {"number": 4682, "name": "CyBears"}, {"number": 488, "name": "Team XBOT"}, {"number": 4911, "name": "CyberKnights"}, {"number": 4915, "name": "Spartronics"}, {"number": 4980, "name": "Canine Crusaders"}, {"number": 5588, "name": "Reign Robotics"}, {"number": 5941, "name": "Cast Iron Orcas"}, {"number": 6350, "name": "Clawbots"}, {"number": 7627, "name": "Bearcat Robotics"}, {"number": 8248, "name": "ChainLynx"}, {"number": 9036, "name": "Ramen Robotics"}, {"number": 949, "name": "Wolverine Robotics"}]}|}

  let ( let* ) = Lwt.bind

let pp_sockaddr fmt = function
  | Unix.ADDR_UNIX name -> Fmt.pf fmt "ADDR_UNIX (name=%s)" name
  | Unix.ADDR_INET (addr, port) ->
      Fmt.pf fmt "ADDR_INET (addr=%s, port=%d)"
        (Unix.string_of_inet_addr addr)
        port

let transform = Uppercase.transform

let run_echo_server ?max_uptime_secs ~uppercase ~port () =
  let* server =
    let* () =
      Logs_lwt.info (fun l ->
          l "Listening on port %d with uppercase %b" port uppercase)
    in
    Lwt_io.establish_server_with_client_address
      (Lwt_unix.ADDR_INET (Unix.inet_addr_any, port))
      (fun (client : Unix.sockaddr) (r, w) ->
        let* () =
          Logs_lwt.info (fun l ->
              l "Connected to client at %a" pp_sockaddr client)
        in
        Lwt_io.read_chars r |> transform ~uppercase |> Lwt_io.write_chars w)
  in
  My_lwt_extras.limit_uptime_or_never_terminate ?max_uptime_secs (fun () ->
      Lwt_io.shutdown_server server)

(* module Match_schedule_table = Match_schedule_table  *)

let create_all_tables db =
  let code = Raw_match_data_table.Table.create_table db in
  let code1 = Match_schedule_table.Table.create_table db in
  let code2 = Robot_pictures_table.Table.create_table db in

  (code, code1, code2)

module Db_utils = Db_utils

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

let initialize db_path =
  let db = Sqlite3.db_open db_path in

  (* FIXME: fail if not successful? *)
  (* FIXME: also need to load match schudle json *)
  let _ = create_all_tables db in

  (* FIXME: REMOVE THIS *)
  (* let _ = Match_schedule_table.Table.fill_database_from_json db sample_json in *)
  fill_raw_match_data_table db;

  db

let pose_to_string pos = Match_schedule_table.Table.robot_position_to_string pos

module type Db_holder = sig
  type t = Sqlite3.db 

  val db : t 

end

module type Database_actions_type = sig
  
  val get_latest_match : unit -> int option 

  val get_matches_for_team : int -> int list

  val get_whole_schedule :
    unit -> (int * int * int * int * int * int * int) list

  val get_missing_records_from_db :
    unit ->
    (int * Match_schedule_table.Table.robot_position list) list
  val initialize : unit -> unit 
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


    (* for java *)
  let generate_qr_code blob = 
    Qr_manager.generate_qr_code blob 

    (* Position referes to type robot_position in Match_schedule_table *)
    (* for java  *)
  let get_team_for_match_and_position team_number position = 
    Match_schedule_table.Table.Fetch.get_team_for_match_and_position Db.db team_number position 

(* for java  *)
  let insert_scouted_data blob = 
    Raw_match_data_table.Table.insert_record Db.db blob 


  let initialize () = 

      let _code = Raw_match_data_table.Table.create_table Db.db in
      let _code1 = Match_schedule_table.Table.create_table Db.db in
      let _code2 = Robot_pictures_table.Table.create_table Db.db in

      let _ = Team_names_table.Table.create_table Db.db in 

      (* sample_json is part of the constructor *)
      let _ = Match_schedule_table.Table.fill_database_from_json Db.db sample_json in

      fill_raw_match_data_table Db.db;

      let _ = Team_names_table.Table.insert_record Db.db sample_json in 
      
      ()

end

let create_object path = 
  let db = Sqlite3.db_open path in 

  let module Fetchable_data = Database_actions (struct
    type t = Sqlite3.db 

    let db = db 
  end) in   

  Fetchable_data.initialize ();


  (module Fetchable_data : Database_actions_type) 




  (* EXAMPLE for ocaml FFI intregration *)
  (* let ask self = `
    let module A = (val self : Database_actions_type) in 

    A.get_latest_match ()  *)










