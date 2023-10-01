let () = print_endline "I am in ManagerApp_ml.ml"

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

  print_endline "I am in ManagerApp_ml.ml [process_qr]";

  let module Db = (val db : SquirrelScout_Std.Database_actions_type) in 

  let args = Array.to_list Sys.argv |> String.concat " " in
  Format.eprintf
    "[%s:%d] I am processing (YAY!) the QR format '%s' with bytes: %s\n\
     Command Line Arguments:%s\n\
     %!"
    __FILE__ __LINE__ qr_format (hex_encode qr_bytes) args


  let main () = 
    let module Db = ( val SquirrelScout_Std.create_object "test.db" ) in 

    Callback.register "squirrel_scout_manager_process_qr" (process_qr (module Db : SquirrelScout_Std.Database_actions_type))


let () = main ()
