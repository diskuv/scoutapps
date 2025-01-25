(* These are hacks until https://gitlab.com/diskuv/distributions/1.0/dksdk-coder/-/issues/7 closed *)
module DkCoderHackPublicPrivateExports1 = Db_utils
module DkCoderHackPublicPrivateExports2 = Schema

(* This file should only be the following line. *)
include Intf.Intf (** @inline *)
val __init : unit -> unit
