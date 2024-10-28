(* let long_string =
   let len = 2953 in
   let buffer = Buffer.create len in

   for _i = 0 to len - 1 do
     Buffer.add_string buffer "{"
   done;

   Buffer.contents buffer *)

(* max length: 2953 *)
let generate_qr_code data =
  let result = Qrc.encode ~ec_level:`L data in
  match result with
  | Some s ->
      let svg = Qrc.Matrix.to_svg s in
      (* print_endline svg; *)
      Ok svg
  | None -> Error ("The QR code could not be generated. Possibilities include that the max length of the data may have exceeded 2953 bytes")
