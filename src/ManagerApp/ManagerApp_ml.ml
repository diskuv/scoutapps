open Bos

(** [hex_encode] modified from https://github.com/mimoo/hexstring. Apache 2.0 license. *)
let hex_encode (bytearray : bytes) : string =
  let dummy_char = '_' in
  let start_of_digit_0_in_ascii_table = 0x30 in
  let start_of_lower_case_a_in_ascii_table = 0x61 in
  let hex_digit_of_int (x : int) : char =
    assert (x >= 0);
    assert (x < 16);
    char_of_int
      (if x < 10 then x + start_of_digit_0_in_ascii_table
       else x - 10 + start_of_lower_case_a_in_ascii_table)
  in
  let rec aux bytearray len cur_pos buf =
    if cur_pos < len then (
      let x = int_of_char @@ Bytes.get bytearray cur_pos in
      let c1 = hex_digit_of_int (x lsr 4) in
      let c2 = hex_digit_of_int (x land 0x0F) in
      Bytes.set buf (cur_pos * 2) c1;
      Bytes.set buf ((cur_pos * 2) + 1) c2;
      aux bytearray len (succ cur_pos) buf)
  in
  let len = Bytes.length bytearray in
  let buf_len = 2 * len in
  let buf = Bytes.make buf_len dummy_char in
  aux bytearray len 0 buf;
  Bytes.to_string buf

let process_qr db qr_format qr_bytes =
  let module Db = (val db : SquirrelScout_Std.Database_actions_type) in
  let rc = Db.process_qr_code qr_bytes in

  match rc with
  | Successful -> Printf.printf "PROCESSED QR CODE SUCCESSFULLY"
  | Failed ->
      Printf.printf "FAILED QR CODE PROCESSING";
      let args = Array.to_list Sys.argv |> String.concat " " in
      Format.eprintf
        "[%s:%d] I am processing (YAY!) the QR format '%s' with bytes: %s\n\
         Command Line Arguments:%s\n\
         %!"
        __FILE__ __LINE__ qr_format (hex_encode qr_bytes) args

let main () =
  (* Set up logging *)
  print_endline "Starting ManagerApp_ml.ml ...";
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Logs.Info);

  (* Parse command line options *)
  let db_path =
    if Array.length Sys.argv < 2 then SquirrelScout_Std.default_db_path ()
    else Fpath.v Sys.argv.(1)
  in

  (* Make sure the database folder is created *)
  let (_created : bool) =
    OS.Dir.create (Fpath.parent db_path) |> Result.get_ok
  in

  (* Create the database module *)
  let db_obj =
    SquirrelScout_Std.create_object ~db_path:(Fpath.to_string db_path) ()
  in
  let module Db = (val db_obj) in
  (* Process QR codes *)
  Callback.register "squirrel_scout_manager_process_qr"
    (process_qr (module Db : SquirrelScout_Std.Database_actions_type))

let () = main ()
