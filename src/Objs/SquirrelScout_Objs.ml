let () = print_endline "in SquirrelScout_objs"


open DkSDKFFIOCaml_Std
open ComStandardSchema.Make (ComMessage.C)
open Com.MakeClassBuilder (ComMessage.C)

let com = Com.create_c ()

let create_object v args =
  let number = Reader.Si32.(i1_get (of_message args)) in
  Ret.v_new v
    (Printf.sprintf "instance constructed with create_object(args = %ld)" number)

let ask ~self v args =
  let question = Reader.St.(i1_get (of_message args)) in
  let ret = Printf.sprintf "I am an %s and I was asked: %s" self question in
  let bldr =
    Builder.St.(
      let r = init_root () in
      i1_set r ret;
      r)
  in
  Ret.v_capnp v bldr

let () =
  register com ~classname:"Basic::Question::Taker"
    [
      class_method ~name:"create_object" ~f:create_object ();
      instance_method ~name:"ask" ~f:ask ();
    ]

module BasicQuestionTaker = struct
  open ComStandardSchema.Make (ComMessage.C)

  let create com = Com.borrow_class_until_finalized com "Basic::Question::Taker"
  let method_create_object = Com.method_id "create_object"
  let method_ask = Com.method_id "ask"

  class questiontaker _clazz inst =
    object
      method ask question =
        let args =
          let open Builder.St in
          let rw = init_root () in
          i1_set rw question;
          to_message rw
        in
        let ret_ptr = Com.call_instance_method inst method_ask args in
        Reader.St.i1_get (Reader.of_pointer ret_ptr)
    end

  let new_questiontaker clazz number =
    let args =
      let open Builder.Si32 in
      let r = init_root () in
      i1_set_int_exn r number;
      to_message r
    in
    Com.call_class_constructor clazz method_create_object
      (new questiontaker clazz)
      args
end

let questiontaker_clazz = BasicQuestionTaker.create com
let questiontaker = BasicQuestionTaker.new_questiontaker questiontaker_clazz 37

let () =
  let actual = questiontaker#ask "What am I?" in
  print_endline actual;
  let expected =
    {|I am an instance constructed with create_object(args = 37) and I was asked: What am I?|}
  in
  if not (String.equal expected actual) then
    failwith
      (Printf.sprintf "Expected {|%s|} but received {|%s|}" expected actual)
