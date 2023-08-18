open Tezt
open SquirrelScout_HelloLib

let tags = [ "hellolib" ]

open Lwt.Syntax

let () =
  Test.register ~__FILE__ ~title:"uppercase:false" ~tags @@ fun () ->
  let* actual =
    transform ~uppercase:false (Lwt_stream.of_string "howdy")
    |> Lwt_stream.to_string
  in
  Check.((actual = "howdy") string) ~error_msg:"expected %R, got %L";
  Lwt.return ()

let () =
  Test.register ~__FILE__ ~title:"uppercase:true" ~tags @@ fun () ->
  let* actual =
    transform ~uppercase:true (Lwt_stream.of_string "howdy")
    |> Lwt_stream.to_string
  in
  Check.((actual = "HOWDY") string) ~error_msg:"expected %R, got %L";
  Lwt.return ()

let () = Test.run ()

let () =
  let engine = Lwt_engine.get () in
  engine#destroy
