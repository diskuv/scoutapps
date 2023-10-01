let do_setup_log style_renderer level =
  Fmt_tty.setup_std_outputs ?style_renderer ();
  Logs.set_level level;
  Logs.set_reporter (Logs_fmt.reporter ())

let setup_log_t =
  Cmdliner.Term.(
    const do_setup_log $ Fmt_cli.style_renderer () $ Logs_cli.level ())

let db_name_t =
  let doc = "file path for sqlite3 database" in
  Cmdliner.Arg.(value & opt string "testing.db" & info ~doc [ "d"; "db" ])

(* -------- *)

let test_print str = print_endline ("printing from test_print: " ^ str)

let test_print_num n =
  print_endline ("printing from test_print_num: " ^ string_of_int n)

let name_t =
  let doc = "name to test print" in
  Cmdliner.Arg.(value & opt string "keyush" & info ~doc [ "n"; "name" ])

let name_print_cmd =
  let info = Cmdliner.Cmd.info "print_name_command" in

  Cmdliner.Cmd.v info Cmdliner.Term.(const test_print $ name_t)

let num_t =
  let doc = "num to print" in
  Cmdliner.Arg.(value & opt int 5 & info ~doc [ "num" ])

let num_print_cmd =
  let info = Cmdliner.Cmd.info "print_number_command" in

  Cmdliner.Cmd.v info Cmdliner.Term.(const test_print_num $ num_t)

let team_num_t =
  let doc = "team to get data for" in

  Cmdliner.Arg.(required & pos 0 (some int) None & info [] ~doc)

(* ------------- *)

module Commands = struct

  module Db = ( val SquirrelScout_Std.create_object "test.db" )
  
  let print_dash = "-----------------------"
  let dummy_flag_t = Cmdliner.Arg.(value & flag & info [ "dummy" ])

  let status =
    let action _flag =
      (* print_endline ("Flag status: " ^ string_of_bool flag); *)

      let latest_match = Db.get_latest_match () in

      let latest_match_string =
        match latest_match with
        | Some x -> string_of_int x
        | None -> "(no matches recorded yet)"
      in

      print_endline print_dash;
      print_endline "DATABASE STATUS";
      print_endline print_dash;

      print_endline ("\n" ^ print_dash);
      print_endline
        ("Lastest match data in database is from match: " ^ latest_match_string);
      print_endline print_dash;

      let missing_data =
        Db.get_missing_records_from_db ()
      in

      let print_match_and_missing_poses num poses =
        print_endline "";
        print_string
          ("*** WARNING *** [MISSING REOCORDS] MATCH: " ^ string_of_int num
         ^ "\n MISSING DATA FROM POSITIONS: ");
        List.iter
          (fun a ->
            let s = SquirrelScout_Std.pose_to_string a in
            print_string (s ^ " "))
          poses;

        print_endline ""
      in

      List.iter
        (fun (num, poses) -> print_match_and_missing_poses num poses)
        missing_data
    in

    let info = Cmdliner.Cmd.info "status" in

    Cmdliner.Cmd.v info Cmdliner.Term.(const action $ dummy_flag_t)

  let matches_for_team =
    let action team =
      let matches =
        Db.get_matches_for_team team
      in

      let rec matches_as_string lst str =
        match lst with
        | [] -> str ^ " | "
        | x :: [] ->
            let new_str = str ^ string_of_int x in
            matches_as_string [] new_str
        | x :: l ->
            let new_str = str ^ string_of_int x ^ ", " in
            matches_as_string l new_str
      in

      let matches_string = matches_as_string matches " | " in

      print_endline (print_dash ^ "\n");
      Printf.printf "MATCHES FOR TEAM %d %s \n" team matches_string;
      print_endline ("\n" ^ print_dash)
    in

    let info = Cmdliner.Cmd.info "matches_for_team" in

    Cmdliner.Cmd.v info Cmdliner.Term.(const action $ team_num_t)

  let match_schedule =
    let action dummy =
      let _ = dummy in

      let match_data = Db.get_whole_schedule () in

      let print_match (match_num, red1, red2, red3, blue1, blue2, blue3) =
        Printf.printf
          "MATCH %d -->   %d     %d     %d     |     %d     %d     %d\n\n"
          match_num red1 red2 red3 blue1 blue2 blue3
      in

      print_endline
        (print_dash
       ^ "\n\
          ALL SCHEDULED MATCHES\n\n\
         \    RED_1    RED_2    RED_3    |    BLUE_1    BLUE_2    BLUE_3\n");

      List.iter (fun a -> print_match a) match_data;

      print_endline print_dash
    in

    let info = Cmdliner.Cmd.info "match_schedule" in

    Cmdliner.Cmd.v info Cmdliner.Term.(const action $ dummy_flag_t)
end

(* let latest_match_cmd =
   let info = Cmdliner.Cmd.info "latest_match" in

   Cmdliner.Cmd.v info Cmdliner.Term.(const print_latest_match) *)

(* let main () =
   let open Cmdliner in
   match
     Cmd.(
       eval
         (v (info "SquirrelScout")
            Term.(
              const SquirrelScout_Std.test_function $ db_name_t $ setup_log_t)))
   with
   | 0 -> exit (if Logs.err_count () > 0 then 2 else 0)
   | ec -> exit ec *)

let main () =
  let doc = "testing group commands" in
  (* let man = Cmdliner.Manpage.s_common_options in   *)
  let info = Cmdliner.Cmd.info "squirrelscout" in

  let cmds =
    [ Commands.status; Commands.matches_for_team; Commands.match_schedule ]
  in

  (* let default =  Cmdliner.Term.(ret (const (fun _ -> `Help (`Pager, None)) *)
  let a = Cmdliner.Cmd.eval (Cmdliner.Cmd.group info cmds) in
  match a with x -> print_endline ("exit code: " ^ string_of_int x)

let () = main ()
