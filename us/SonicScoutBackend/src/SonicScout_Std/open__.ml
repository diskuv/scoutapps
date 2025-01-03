module Sqlite3 = Tr1SQLite3_Std.Sqlite3
module Capnp = Tr1Capnp_Std.Capnp
module Logs = Tr1Logs_Std.Logs
module Yojson = Tr1Json_Yojson2.Yojson
module Qrc = Tr1Qrc_Std.Qrc
module Bytes = Tr1Stdlib_V414Base.Bytes
module Queue = Tr1Stdlib_V414Base.Queue
module String = Tr1Stdlib_V414Base.String
module List = Tr1Stdlib_V414Base.List
module Int64 = Tr1Stdlib_V414Base.Int64
module Printf = Tr1Stdlib_V414CRuntime.Printf
module Format = Tr1Stdlib_V414CRuntime.Format
module Result = Tr1Stdlib_V414Base.Result
module Sys = Tr1Stdlib_V414CRuntime.Sys
module Fpath = Tr1Fpath_Std.Fpath

(* Maintain compatibility with unshadowed OCaml *)
let prerr_endline = Tr1Stdlib_V414Io.StdIo.prerr_endline
let print_endline = Tr1Stdlib_V414Io.StdIo.print_endline
let open_out = Tr1Stdlib_V414Io.StdIo.open_out
let close_out = Tr1Stdlib_V414Io.StdIo.close_out

module _ = DkSDKFFI_OCaml
(** The bridge between OCaml and other programming languages.

    {[ `v1 [
         `sec [ `scheme "dkcoder" ];
         `kind (
           `std [
             `blib ["https://gitlab.com/api/v4/projects/62703194/packages/generic/@DKML_TARGET_ABI@/2.2.1/@DKML_TARGET_ABI@-4.14.2-DkSDKFFI_OCaml-2.2.1-none.blib.zip"];
             `clib ["https://gitlab.com/api/v4/projects/62703194/packages/generic/@DKML_TARGET_ABI@/2.2.1/@DKML_TARGET_ABI@-4.14.2-DkSDKFFI_OCaml-2.2.1-none.clib.zip"];
            ]
          )
        ] ]} *)
