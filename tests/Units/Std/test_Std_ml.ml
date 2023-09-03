open Tezt
open SquirrelScout_Std

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


let () = 
  Tezt.Test.register ~__FILE__ ~title:"DB: create all tables" ~tags @@ fun () -> 
    let db = Sqlite3.db_open "testing.db" in 
    let a, b, c = SquirrelScout_Std.create_all_tables db in 
    let result_strings = (SquirrelScout_Std.Db_utils.return_code_to_string a, SquirrelScout_Std.Db_utils.return_code_to_string b, SquirrelScout_Std.Db_utils.return_code_to_string c) in 
    
    let expected = ("Successful", "Successful", "Successful") in 

    Check.((result_strings = expected) (tuple3 string string string) ) ~error_msg:"expected %R, got %L";
    Lwt.return ()



let () = Test.run ()

let () =
  let engine = Lwt_engine.get () in
  engine#destroy
