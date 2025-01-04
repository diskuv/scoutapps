module Cmdliner = Tr1Cmdliner_Std.Cmdliner
module Format = Tr1Stdlib_V414CRuntime.Format
module Fpath = Tr1Fpath_Std.Fpath
module In_channel = Tr1Stdlib_V414CRuntime.In_channel
module Logs = Tr1Logs_Std.Logs
module List = Tr1Stdlib_V414Base.List
module Printf = Tr1Stdlib_V414CRuntime.Printf

(* This is a bridge until we use DkCoder exclusively for both byte and native code. *)
module Fmt_tty = struct
  let setup_std_outputs ?style_renderer () =
    ignore style_renderer;
    Tr1Logs_Term.TerminalCliOptions.init ()
end

(* This is a bridge until we use DkCoder exclusively for both byte and native code. *)
module Fmt_cli = struct
  open Cmdliner

  let style_renderer :
      ?env:Cmd.Env.info ->
      ?docs:string ->
      unit ->
      Fmt.style_renderer option Term.t =
   fun ?env ?docs () ->
    ignore env;
    ignore docs;
    Term.const None
end

(* This is a bridge until we use DkCoder exclusively for both byte and native code. *)
module Logs_cli = struct
  let level () = Cmdliner.Term.const (Some Logs.Info)
end

(* This is a bridge until we use DkCoder exclusively for both byte and native code. *)
module Logs_fmt = struct
  let reporter
      ?(pp_header :
         (Format.formatter -> Logs.level * string option -> unit) option)
      ?(app : Format.formatter option) ?(dst : Format.formatter option) () =
    ignore pp_header;
    ignore app;
    ignore dst;
    Tr1Logs_Term.TerminalCliOptions.init ();
    Logs.reporter ()
end

(* DkSDK CMake does not wrap modules, so in DkCoder we unwrap here. *)
module StdEntry = SonicScout_Std.StdEntry

let exit = Tr1Stdlib_V414CRuntime.StdExit.exit
let print_endline = Tr1Stdlib_V414Io.StdIo.print_endline
let print_string = Tr1Stdlib_V414Io.StdIo.print_string
