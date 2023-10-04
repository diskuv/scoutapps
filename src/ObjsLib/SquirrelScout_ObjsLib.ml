(* Automatically register the COM objects *)
let com = DkSDKFFIOCaml_Std.Com.create_c ()
let () = SquirrelScout_Objs.register_objects com
