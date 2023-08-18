(** This file exists to demonstrate .ml source code can be
    in any directory or subdirectory of DkSDKProject_AddPackage().

    Source: https://github.com/dkim/rwo-lwt
*)

(** [transform ~uppercase stream] converts a [stream] into another stream
    that has been all upper-cased (if and only if [~uppercase = true]).

    If [~uppercase = false] then the returned stream is the original
    stream.
 *)
let transform ~uppercase =
  if uppercase then Lwt_stream.map Char.uppercase_ascii else fun x -> x
