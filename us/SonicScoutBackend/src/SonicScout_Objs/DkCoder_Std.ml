(* Since the filename is a library id, this module will be ignored by DkCoder.
   Just provides a typed no-op for DkSDK CMake. *)

module type SCRIPT = sig end
module Script : SCRIPT = struct end
