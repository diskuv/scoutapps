(* Always make sure there is a full backtrace available *)
let () = Printexc.record_backtrace true

(* Automatically register the COM objects when the COM system is initialized *)
let () = DkSDKFFI_OCaml.ComEvents.add_init_event_handler (fun () ->
  let com = DkSDKFFI_OCaml.Com.create_c () in
  SquirrelScout_Objs.register_objects com)
