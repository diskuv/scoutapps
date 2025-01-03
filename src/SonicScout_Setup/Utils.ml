(** {1 Options} *)

type opts = {
  next : bool;
  fetch_siblings : bool;
  build_type : [ `Debug | `Release ];
      (** On Windows the [`Debug] build type is not redistributable
          (can't be moved to other machines).
          It will only work if ["ucrtbased.dll"] and other debug DLLs
          can be located, and that usually only if Visual Studio is installed
          on the user's PC. We can't copy the "d" DLLs either because
          Microsoft restricts redistribution of the debug DLLS. *)
}

(** [default_opts] are the default options.

    The default build type is [`Release] since [`Debug] is not redistributable
    on Windows. *)
let default_opts : opts =
  { next = false; fetch_siblings = false; build_type = `Release }

(** {1 Progress} *)

let step = ref 1

let start_step, done_steps =
  let blue = Fmt.styled (`Fg (`Hi `Blue)) in
  let red = Fmt.styled (`Fg (`Hi `Red)) in
  let pp_arrow ~c ppf n =
    Fmt.array ~sep:(Fmt.any "")
      (fun ppf (even, c) ->
        if even then blue Fmt.char ppf c else red Fmt.char ppf c)
      ppf
      (Array.make n c |> Array.mapi (fun i c -> (i mod 10 < 5, c)))
  in
  let start s =
    Logs.info (fun l ->
        l "%a"
          (Fmt.styled `Bold (fun ppf v ->
               Fmt.pf ppf "%a Step %d - %s %a" (pp_arrow ~c:'>') 10 v s
                 (pp_arrow ~c:'<') 10))
          !step);
    step := !step + 1
  in
  let done_ s =
    Logs.info (fun l ->
        l "%a"
          (Fmt.styled `Bold (fun ppf () ->
               Fmt.pf ppf "%a Done - %s %a" (pp_arrow ~c:'>') 10 s
                 (pp_arrow ~c:'<') 10))
          ())
  in
  (start, done_)

(** {1 Error Handling}  *)

exception StopProvisioning

let rmsg = function Ok v -> v | Error (`Msg msg) -> failwith msg

(** {1 Running with slots} *)

(** [slot_env ?env ~slots ()] prepends the [paths] in [slots]
    to the PATH of the returned environment, with [env] being the
    initial environment.
    
    If there is no initial environment then the current environment
    is used instead. *)
let slot_env ?env ~slots () =
  let open Bos in
  (* Prepend [paths] to PATH *)
  let sepchar_PATH = if Sys.win32 then ';' else ':' in
  let env =
    match env with Some env -> env | None -> Bos.OS.Env.current () |> rmsg
  in
  let env_PATH =
    match OSEnvMap.find "PATH" env with
    | None -> []
    | Some path -> String.split_on_char sepchar_PATH path
  in
  let slots_PATH = Slots.paths slots |> List.map Fpath.to_string in
  let sepstring_PATH = String.make 1 sepchar_PATH in
  OSEnvMap.add "PATH" (String.concat sepstring_PATH (slots_PATH @ env_PATH)) env

(** {1 Running wsl2} *)

let wsl2_env ~env () =
  let open Bos in
  let env =
    match env with Some env -> env | None -> OS.Env.current () |> rmsg
  in
  (* UTF-16 encoding by default. https://stackoverflow.com/a/72324672/21513816.
     But not all WSL versions support it. So we do [recode_into_utf8] as well. *)
  OSEnvMap.add "WSL_UTF8" "1" env

(* Similar to https://erratique.ch/software/uutf/doc/Uutf/index.html#examples
   but using UTF functions in OCaml 4.14.

   nit: Duplicated in dksdk-coder\src\Gen\capnp\capnp_render.ml.
   If duplicated one more time, this function needs to be elevated to a
   Tr1String_* library. *)
let utf8_lines_of_unicode (src : string) =
  match String.length src with
  | 0 -> []
  | src_len ->
      let decoder =
        (* Check first bytes to see if UTF-8.
            We'll use a full string check for detecting UTF-16 endianness. *)
        if Uchar.utf_decode_is_valid (String.get_utf_8_uchar src 0) then
          String.get_utf_8_uchar
        else if String.is_valid_utf_16be src then String.get_utf_16be_uchar
        else if String.is_valid_utf_16le src then String.get_utf_16le_uchar
        else failwith "The UTF encoding could not be determined"
      in
      let rec loop i buf acc =
        if i >= src_len then List.rev (Buffer.contents buf :: acc)
        else
          let d = decoder src i in
          let i_next = i + Uchar.utf_decode_length d in
          let u = Uchar.utf_decode_uchar d in
          match Uchar.to_int u with
          | 0x000D ->
              (* skip carriage return *)
              loop i_next buf acc
          | 0x000A ->
              (* newline *)
              let line = Buffer.contents buf in
              Buffer.clear buf;
              loop i_next buf (line :: acc)
          | _ ->
              (* accumulate *)
              Buffer.add_utf_8_uchar buf u;
              loop i_next buf acc
      in
      loop 0 (Buffer.create 512) []

let wsl2_list ?env args =
  let open Bos in
  let env = wsl2_env ~env () in
  Logs.info (fun l ->
      l "wsl --list%s%a"
        (if args = [] then "" else " ")
        (Fmt.list ~sep:Fmt.sp Fmt.string)
        args);
  let out =
    OS.Cmd.run_out ~env Cmd.(v "wsl" % "--list" %% of_list args)
    |> OS.Cmd.out_string |> OS.Cmd.success |> rmsg
  in
  let lines = utf8_lines_of_unicode out |> List.map String.trim in
  List.filter
    (fun s -> not (String.equal "Windows Subsystem for Linux Distributions:" s))
    lines

let wsl2 ?env args =
  let open Bos in
  let env = wsl2_env ~env () in
  Logs.info (fun l -> l "wsl %a" (Fmt.list ~sep:Fmt.sp Fmt.string) args);
  OS.Cmd.run ~env Cmd.(v "wsl" %% of_list args) |> rmsg

(** {1 Running git} *)

let git ~slots args =
  let open Bos in
  Logs.info (fun l -> l "git %a" (Fmt.list ~sep:Fmt.sp Fmt.string) args);
  let git_exe =
    match Slots.git slots with
    | Some exe -> Cmd.(v (p exe))
    | None -> Cmd.v "git"
  in
  OS.Cmd.run Cmd.(git_exe %% of_list args) |> rmsg

(** {1 Running ./dk} *)

let dk ?env ~slots args =
  let open Bos in
  Logs.info (fun l -> l "./dk %a" (Fmt.list ~sep:Fmt.sp Fmt.string) args);
  (* Add [slots] to PATH *)
  let env = slot_env ?env ~slots () in
  (* Run ./dk *)
  let script = if Sys.win32 then Cmd.v ".\\dk.cmd" else Cmd.v "./dk" in
  OS.Cmd.run ~env Cmd.(script %% of_list args) |> rmsg

(** [sibling_dir_mixed] is the directory of the project [project]
    that is directly next (a "sibling") to the current directory [cwd].

    The return value is a mixed path directory, where all backslashes are
    replaced with forward slashes. On Unix the path does not change. But on
    Windows an example would be ["C:/x/y/z"]. *)
let sibling_dir_mixed ~cwd ~project =
  let parentdir_mixed =
    Fpath.parent cwd |> Fpath.to_string
    |> Stringext.replace_all ~pattern:"\\" ~with_:"/"
  in
  if String.ends_with ~suffix:"/" parentdir_mixed then
    Printf.sprintf "%s%s" parentdir_mixed project
  else Printf.sprintf "%s/%s" parentdir_mixed project

let dk_env ?(opts = default_opts) () =
  let env = Bos.OS.Env.current () |> rmsg in
  let cwd = Bos.OS.Dir.current () |> rmsg in
  let sib project =
    let project_upcase_underscore =
      String.uppercase_ascii project
      |> Stringext.replace_all ~pattern:"-" ~with_:"_"
    in
    Bos.OSEnvMap.add
      (Printf.sprintf "%s_REPO_1_0" project_upcase_underscore)
      (Printf.sprintf "file://%s/.git" (sibling_dir_mixed ~cwd ~project))
  in
  if opts.fetch_siblings then
    (sib "dksdk-cmake") env
    |> sib "dksdk-ffi-c" |> sib "dksdk-ffi-java" |> sib "dksdk-ffi-ocaml"
  else env
