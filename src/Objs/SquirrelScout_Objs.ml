let () = print_endline "in SquirrelScout_Objs"

open DkSDKFFIOCaml_Std
open ComStandardSchema.Make (ComMessage.C)
open Com.MakeClassBuilder (ComMessage.C)
module ProjectSchema = SquirrelScout_Std.Schema.Make (ComMessage.C)

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

(* args: [RawMatchData]. return: [MaybeError] *)
let insert_scouted_data ~self v args =
  let module Db = (val self : SquirrelScout_Std.Database_actions_type) in
  (* For some reason Db.insert_scouted_data uses a string rather than Capnp.
     So we just validate that [args] is RawMatchData.
     TODO: fix that *)
  let (_ : ProjectSchema.Reader.RawMatchData.t) =
    ProjectSchema.Reader.RawMatchData.of_message args
  in
  let raw_match_data_as_string = ComCodecs.serialize ~compression:`None args in

  match Db.insert_scouted_data raw_match_data_as_string with
  | Failed ->
      let bldr = ProjectSchema.Builder.MaybeError.init_root () in
      ProjectSchema.Builder.MaybeError.success_set bldr false;
      ProjectSchema.Builder.MaybeError.message_if_error_set bldr
        "The scout data could not be inserted";
      Ret.v_capnp v bldr
  | Successful ->
      let bldr = ProjectSchema.Builder.MaybeError.init_root () in
      ProjectSchema.Builder.MaybeError.success_set bldr true;
      Ret.v_capnp v bldr


  let load_json_match_schedule ~self v args = 
    let module Db = (val self : SquirrelScout_Std.Database_actions_type) in

    let bldr = ProjectSchema.Builder.MaybeError.init_root () in 

    let json_contents = Reader.St.(i1_get (of_message args)) in
    match Db.insert_match_json ~json_contents:json_contents () with 
    | Failed -> 
      ProjectSchema.Builder.MaybeError.success_set bldr false;
      ProjectSchema.Builder.MaybeError.message_if_error_set bldr "match schedule json could not be loaded";
      Ret.v_capnp v bldr 

    | Successful -> 
      ProjectSchema.Builder.MaybeError.success_set bldr true;
      Ret.v_capnp v bldr 


let register_objects com =
  register com ~classname:"SquirrelScout::Database"
    [
      class_method ~name:"create_object" ~f:create_object ();

      instance_method ~name:"get_team_for_match_and_position"
        ~f:get_team_for_match_and_position ();
      instance_method ~name:"insert_scouted_data" ~f:insert_scouted_data ();
      instance_method ~name:"load_json_match_schedule" ~f:load_json_match_schedule ();
    ];
  register com ~classname:"SquirrelScout::QR"
    [
      class_method ~name:"generate" ~f:generate_qr_code ();
    ]
