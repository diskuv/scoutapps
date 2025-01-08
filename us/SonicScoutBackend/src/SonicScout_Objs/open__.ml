module Capnp = Tr1Capnp_Std.Capnp
module Int = Tr1Stdlib_V414Base.Int

let print_endline = Tr1Stdlib_V414Io.StdIo.print_endline

(* DkSDK CMake does not wrap modules, so in DkCoder we unwrap here. *)
module StdEntry = SonicScout_Std.StdEntry
