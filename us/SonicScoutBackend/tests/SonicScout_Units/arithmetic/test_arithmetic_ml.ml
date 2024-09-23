open Tezt
open Arithmetic

let tags = [ "arithmetic" ]

let () =
  Test.register ~__FILE__ ~title:"add" ~tags @@ fun () ->
  Check.((add 7 3 = 10) int) ~error_msg:"expected `add 7 3` = %R, got %L";
  Lwt.return ()

let () =
  Test.register ~__FILE__ ~title:"subtract" ~tags @@ fun () ->
  Check.((subtract 7 3 = 4) int)
    ~error_msg:"expected `subtract 7 3` = %R, got %L";
  Lwt.return ()

let () =
  Test.register ~__FILE__ ~title:"multiply" ~tags @@ fun () ->
  Check.((multiply 7 3 = 21) int)
    ~error_msg:"expected `multiply 7 3` = %R, got %L";
  Lwt.return ()

let () =
  Test.register ~__FILE__ ~title:"divide" ~tags @@ fun () ->
  let ans = divide 7 3 in
  Check.((ans >= 2.33) float) ~error_msg:"expected `divide 7 3` >= %R, got %L";
  Check.((ans <= 2.34) float) ~error_msg:"expected `divide 7 3` <= %R, got %L";
  Lwt.return ()

let () = Test.run ()

let () =
  let engine = Lwt_engine.get () in
  engine#destroy
