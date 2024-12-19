open Tezt
open DkSDKFFI_OCaml
module ProjectSchema = StdEntry.Schema.Make (ComMessageC)

let tags = [ "objs" ]

(* This module is for testing the SquirrelScout::QR object in OCaml.
   The Java code is the real code, but the Java code should do the same Capnp
   conversions as this test! *)
module QRTest = struct
  open ComStandardSchema.Make (ComMessageC)
  let create com = Com.borrow_class_until_finalized com "SquirrelScout::QR"
  let method_qr_code_of_raw_match_data = Com.method_id "qr_code_of_raw_match_data"

  let qr_code_of_raw_match_data cls ~scouter_name ~notes () =
    let args =
      let open ProjectSchema.Builder.RawMatchData in
      let r = init_root () in
      scouter_name_set r scouter_name;
      (* notes_set r notes; *)
      ignore notes;
      to_message r
    in
    let ret_ptr = Com.call_class_method cls method_qr_code_of_raw_match_data args in
    Reader.Sd.i1_get (Reader.of_pointer ret_ptr)
end
     
(* This module is for testing the SquirrelScout::Database object in OCaml.
   The Java code is the real code, but the Java code should do the same Capnp
   conversions as this test! *)
module DatabaseTest = struct
  open ComStandardSchema.Make (ComMessageC)

  let create com = Com.borrow_class_until_finalized com "SquirrelScout::Database"
  let method_create_object = Com.method_id "create_object"

  let method_get_team_for_match_and_position =
    Com.method_id "get_team_for_match_and_position"

  let method_insert_scouted_data = Com.method_id "insert_scouted_data"

  class database _clazz inst =
    object
      method get_team_for_match_and_position (matchnum : int)
          (position : StdEntry.Types.robot_position) =
        let args =
          let open ProjectSchema.Builder in
          let pos : RobotPosition.t =
            match position with
            | Red_1 -> Red1
            | Red_2 -> Red2
            | Red_3 -> Red3
            | Blue_1 -> Blue1
            | Blue_2 -> Blue2
            | Blue_3 -> Blue3
          in
          let rw = MatchAndPosition.init_root () in
          MatchAndPosition.match_set_exn rw matchnum;
          MatchAndPosition.position_set rw pos;
          MatchAndPosition.to_message rw
        in
        let ret_ptr =
          Com.call_instance_method inst method_get_team_for_match_and_position
            args
        in
        Reader.Si16.i1_get (Reader.of_pointer ret_ptr)

      method insert_scouted_data
          (raw_match_data : ComStandardSchema.rw ProjectSchema.message_t) =
        let ret_ptr =
          Com.call_instance_method inst method_insert_scouted_data
            raw_match_data
        in
        let r = Reader.of_pointer ret_ptr in
        if ProjectSchema.Reader.MaybeError.success_get r then ()
        else failwith (ProjectSchema.Reader.MaybeError.message_if_error_get r)
    end

  let new_database cls db_path =
    let args =
      let open Builder.St in
      let r = init_root () in
      i1_set r db_path;
      to_message r
    in
    Com.call_class_constructor cls method_create_object
      (new database cls)
      args
end

let com = Com.create_c ()
let () = SquirrelScout_Objs.register_objects com
let qr_cls = QRTest.create com
let database_cls = DatabaseTest.create com

let () =
  Tezt.Test.register ~__FILE__ ~title:"qr_code_of_raw_match_data" ~tags @@ fun () ->
  let actual =
    QRTest.qr_code_of_raw_match_data qr_cls
      ~scouter_name:"Me"
      ~notes:"What am I?" ()
  in
  let expected_first_line =
    {|<svg xmlns='http://www.w3.org/2000/svg' version='1.1' width='50mm' height='50mm' viewBox='0 0 45 45'>|}
  in
  let actual_first_newline = String.index actual '\n' in
  let actual_first_line =
    String.sub actual 0 actual_first_newline |> String.trim
  in
  Check.((expected_first_line = actual_first_line) string)
    ~error_msg:"expected first line of QR code image to be %L, got %R";
  Lwt.return ()

let () =
  Tezt.Test.register ~__FILE__ ~title:"get_team_for_match_and_position" ~tags
  @@ fun () ->
  let db_path = Tezt.Temp.file "test.db" in
  let database = DatabaseTest.new_database database_cls db_path in
  let actual = database#get_team_for_match_and_position 1 Red_2 in
  Check.((actual = -1) int)
    ~error_msg:
      "expected team = -1 (that is 'not found') but instead received %L";
  Lwt.return ()

let () =
  Tezt.Test.register ~__FILE__ ~title:"insert_scouted_data" ~tags @@ fun () ->
  let db_path = Tezt.Temp.file "test.db" in
  let database = DatabaseTest.new_database database_cls db_path in
  let scouted_data =
    ProjectSchema.Builder.RawMatchData.(
      let bldr = init_root () in
      scouter_name_set bldr "test insert_scouted_data";
      bldr |> to_message)
  in
  database#insert_scouted_data scouted_data;
  Lwt.return ()

let () = Test.run ()

let () =
  let engine = Lwt_engine.get () in
  engine#destroy
