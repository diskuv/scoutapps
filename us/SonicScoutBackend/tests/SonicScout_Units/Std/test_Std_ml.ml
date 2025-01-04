open Tezt
open StdEntry

let tags = [ "std" ]

let () =
  Tezt.Test.register ~__FILE__ ~title:"DB: create all tables" ~tags @@ fun () ->
  let db = Sqlite3.db_open "testing.db" in
  let rc = For_testing.create_all_tables db in
  let result_strings =
    ( For_testing.return_code_to_string rc )
  in

  let expected = ("Successful") in

  Check.((result_strings = expected) string)
    ~error_msg:"expected %R, got %L";
  Lwt.return ()

let () = Test.run ()

let () =
  let engine = Lwt_engine.get () in
  engine#destroy
