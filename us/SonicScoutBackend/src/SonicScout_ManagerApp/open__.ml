module Array = Tr1Stdlib_V414Base.Array
module Bos = Tr1Bos_Std.Bos
module Bytes = Tr1Stdlib_V414Base.Bytes
module Callback = Tr1Stdlib_V414CRuntime.Callback
module Format = Tr1Stdlib_V414CRuntime.Format
module Logs = Tr1Logs_Std.Logs
module Printf = Tr1Stdlib_V414CRuntime.Printf
module Result = Tr1Stdlib_V414Base.Result
module String = Tr1Stdlib_V414Base.String
module Sys = Tr1Stdlib_V414CRuntime.Sys
let print_endline = Tr1Stdlib_V414Io.StdIo.print_endline

(* This is a bridge until we use DkCoder exclusively for both byte and native code. *)
module Logs_fmt = struct
  let reporter ?(pp_header:(Format.formatter -> (Logs.level * string option) -> unit) option) 
    ?(app:Format.formatter option) ?(dst:Format.formatter option) () =
    ignore pp_header;
    ignore app;
    ignore dst;
    Tr1Logs_Term.TerminalCliOptions.init ();
    Logs.reporter ()
end

(* DkSDK CMake does not wrap modules, so in DkCoder we unwrap here. *)
module StdEntry = SonicScout_Std.StdEntry
module Robot_pictures_table = SonicScout_Std.Robot_pictures_table
