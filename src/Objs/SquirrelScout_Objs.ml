let () = print_endline "in SquirrelScout_Objs"

open DkSDKFFIOCaml_Std
open ComStandardSchema.Make (ComMessage.C)
open Com.MakeClassBuilder (ComMessage.C)
module ProjectSchema = SquirrelScout_Std.Schema.Make (ComMessage.C)

let com = Com.create_c ()

(* args: [TEXT]. return: <new object> *)
let create_object v args =
  let db_path = Reader.St.(i1_get (of_message args)) in
  let obj = SquirrelScout_Std.create_object ~db_path () in
  Ret.v_new v obj

(* args: [DATA]. return: [DATA] *)
let generate_qr_code v args =
  let blob = Reader.Sd.(i1_get (of_message args)) in
  match SquirrelScout_Std.generate_qr_code blob with
  | Error msg -> failwith msg
  | Ok qrcode ->
      let bldr =
        Builder.Sd.(
          let r = init_root () in
          i1_set r qrcode;
          r)
      in
      Ret.v_capnp v bldr

(* args: [MatchAndPosition]. return: [Int16 where -1 is not found] *)
let get_team_for_match_and_position ~self v args =
  let module Db = (val self : SquirrelScout_Std.Database_actions_type) in
  let matchnum, position =
    let open ProjectSchema.Reader in
    let m = MatchAndPosition.of_message args in
    let matchnum = MatchAndPosition.match_get m in
    let position : SquirrelScout_Std.Types.robot_position =
      match MatchAndPosition.position_get m with
      | Red1 -> Red_1
      | Red2 -> Red_2
      | Red3 -> Red_3
      | Blue1 -> Blue_1
      | Blue2 -> Blue_2
      | Blue3 -> Blue_3
      | Undefined n ->
          raise
            (Invalid_argument
               ("Expected a RobotPosition capnp enum value, but instead \
                 received enum index " ^ Int.to_string n))
    in
    (matchnum, position)
  in
  let bldr = Builder.Si16.init_root () in
  (match Db.get_team_for_match_and_position matchnum position with
  | None -> Builder.Si16.i1_set_exn bldr (-1)
  | Some team -> Builder.Si16.i1_set_exn bldr team);
  Ret.v_capnp v bldr

(*
let insert_scouted_data ~self v args =
   let module Db = ( val self : SquirrelScout_Std.Database_actions_type) in
   ...
*)

let () =
  register com ~classname:"SquirrelScout::Bridge"
    [
      class_method ~name:"create_object" ~f:create_object ();
      class_method ~name:"generate_qr_code" ~f:generate_qr_code ();
      instance_method ~name:"get_team_for_match_and_position"
        ~f:get_team_for_match_and_position ();
      (* instance_method ~name:"insert_scouted_data" ~f:insert_scouted_data (); *)
    ]

(* This module is for testing the Bridge object in OCaml.
   The Java code is the real code, but the Java code should do the same Capnp
   conversions as this test! *)
module BridgeTest = struct
  open ComStandardSchema.Make (ComMessage.C)

  let create com = Com.borrow_class_until_finalized com "SquirrelScout::Bridge"
  let method_create_object = Com.method_id "create_object"
  let method_generate_qr_code = Com.method_id "generate_qr_code"

  let method_get_team_for_match_and_position =
    Com.method_id "get_team_for_match_and_position"

  let method_insert_scouted_data = Com.method_id "insert_scouted_data"

  class bridge _clazz inst =
    object
      method get_team_for_match_and_position (matchnum : int)
          (position : SquirrelScout_Std.Types.robot_position) =
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
      (* method insert_scouted_data match position =
         let args =
           let open Builder.St in
           let rw = init_root () in
           i1_set rw question;
           to_message rw
         in
         let ret_ptr = Com.call_instance_method inst method_ask args in
         Reader.St.i1_get (Reader.of_pointer ret_ptr) *)
    end

  let new_bridge clazz db_path =
    let args =
      let open Builder.St in
      let r = init_root () in
      i1_set r db_path;
      to_message r
    in
    Com.call_class_constructor clazz method_create_object
      (new bridge clazz)
      args

  let generate_qr_code clazz blob =
    let args =
      let open Builder.Sd in
      let r = init_root () in
      i1_set r blob;
      to_message r
    in
    let ret_ptr = Com.call_class_method clazz method_generate_qr_code args in
    Reader.Sd.i1_get (Reader.of_pointer ret_ptr)
end

let bridge_clazz = BridgeTest.create com

let () =
  let actual = BridgeTest.generate_qr_code bridge_clazz "What am I?" in
  let expected_first_line =
    {|<svg xmlns='http://www.w3.org/2000/svg' version='1.1' width='50mm' height='50mm' viewBox='0 0 29 29'>|}
  in
  let actual_first_newline = String.index actual '\n' in
  let actual_first_line =
    String.sub actual 0 actual_first_newline |> String.trim
  in
  if not (String.equal expected_first_line actual_first_line) then
    failwith
      (Printf.sprintf
         "Expected first line of QR code image to be {|%s|} but received {|%s|}"
         expected_first_line actual_first_line)

let bridge = BridgeTest.new_bridge bridge_clazz "bridge-test.db"

let () =
  let actual = bridge#get_team_for_match_and_position 1 Red_2 in
  if actual <> -1 then
    failwith
      (Printf.sprintf "Expected team = -1 (not found) but instead received %d"
         actual)
