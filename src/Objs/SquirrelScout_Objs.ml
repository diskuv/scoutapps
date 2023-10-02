let () = print_endline "in SquirrelScout_Objs"

open DkSDKFFIOCaml_Std
open ComStandardSchema.Make (ComMessage.C)
open Com.MakeClassBuilder (ComMessage.C)

let com = Com.create_c ()

(* args: [TEXT] *)
let create_object v args =
  let db_path = Reader.St.(i1_get (of_message args)) in
  let obj = SquirrelScout_Std.create_object ~db_path () in
  Ret.v_new v obj

(* args: [DATA] *)
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

(*
let get_team_for_match_and_position ~self v args =
   let module Db = ( val self : SquirrelScout_Std.Database_actions_type) in
   ...
let insert_scouted_data ~self v args =
   let module Db = ( val self : SquirrelScout_Std.Database_actions_type) in
   ...
*)

let () =
  register com ~classname:"SquirrelScout::Bridge"
    [
      class_method ~name:"create_object" ~f:create_object ();
      class_method ~name:"generate_qr_code" ~f:generate_qr_code ();
      (* instance_method ~name:"get_team_for_match_and_position" ~f:generateget_team_for_match_and_position_qr_code (); *)
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

  class bridge _clazz _inst =
    object
      (* method get_team_for_match_and_position match position =
         let args =
           let open Builder.St in
           let rw = init_root () in
           i1_set rw question;
           to_message rw
         in
         let ret_ptr = Com.call_instance_method inst method_ask args in
         Reader.St.i1_get (Reader.of_pointer ret_ptr) *)
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

(* let bridge = BridgeTest.new_bridge bridge_clazz "bridge-test.db"

   let () =
     let actual = bridge#ask "What am I?" in
     print_endline actual;
     let expected =
       {|I am an instance constructed with create_object(args = 37) and I was asked: What am I?|}
     in
     if not (String.equal expected actual) then
       failwith
         (Printf.sprintf "Expected {|%s|} but received {|%s|}" expected actual) *)
