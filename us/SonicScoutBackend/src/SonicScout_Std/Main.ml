(* [@@@ocaml.warning "-32-37"] *)

(* let db = Sqlite3.db_open "test.db" *)

(* let x = Raw_match_data_table.create_table  *)

(* let sample_match_schudle_data : Match_schedule_table.match_schudle_record =
     {
       match_number = 1;
       red_1 = 2930;
       red_2 = 2910;
       red_3 = 254;
       blue_1 = 1678;
       blue_2 = 2056;
       blue_3 = 118;
     }

   let sample_robot_image_data : Robot_pictures_table.robot_picture_record =
     { team_number = 2930; image = "dsadsadwasdhawdhsakdhqwiyd" }

   let print_to_console_cb row headers =
     let n = Array.length row - 1 in
     let () =
       for i = 0 to n do
         let value = match row.(i) with Some s -> s | None -> "Null" in
         Printf.printf "| %s: %s |" headers.(i) value
       done
     in
     print_endline "" *)

(* TODO: https://ocaml.org/p/vector/latest/doc/Vector/index.html *)

(* let () =
   let x = Match_schudle_table.get_team_for_match_and_position db 4 Blue_3 in
   match x with
   | Some y -> print_endline ("TEAM NUMBER " ^ string_of_int y)
   | None -> print_endline("NO RESULT") *)

(* let test_insert_records =
   let _ = Raw_match_data_table.insert_db_record sample_scouted_data in
   let _ = Match_schudle_table.insert_match_schudle_record sample_match_schudle_data in
   let _ = Robot_pictures.insert_robot_picture_record sample_robot_image_data in
   () *)

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

(* let () =
   let db = Sqlite3.db_open "test.db" in
   create_all_tables db *)

(* let () =
   let str = encode in
   let by = Bytes.of_string str in

   for i = 0 to Bytes.length by do
     let b = Bytes.get by 1 in
     print_endline ("i: " ^ (string_of_int i) ^ "|| char: " ^ ( String.make 1 b))
   done *)

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

(* module Foo = Foo.Make (Capnp.BytesMessage) *)
(*
   module ProjectSchema = StdEntry.Schema (Capnp.BytesMessage)

   let test =
     let rw = Schema.Builder.RawMatchData.init_root () in

     Schema.Builder.RawMatchData.auto_cone_high_set_exn rw 6;

     let c = Schema.Builder.Climb.Docked in

     Schema.Builder.RawMatchData.auto_climb_set rw c;

     Schema.Builder.RawMatchData.auto_cone_mid_set_exn rw 4;

     let message = Schema.Builder.RawMatchData.to_message rw in

     Capnp.Codecs.serialize ~compression:`None message

     let () =
       let binary_data = test in

       Aws_manager.send_sqs binary_data *)
