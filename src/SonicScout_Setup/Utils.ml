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

let wsl2_list args =
  let open Bos in
  Logs.info (fun l ->
      l "wsl --list%s%a"
        (if args = [] then "" else " ")
        (Fmt.list ~sep:Fmt.sp Fmt.string)
        args);
  let lines, _status =
    OS.Cmd.run_out Cmd.(v "wsl" % "--list" %% of_list args)
    |> OS.Cmd.out_lines |> rmsg
  in
  List.filter
    (fun s -> not (String.equal "Windows Subsystem for Linux Distributions:" s))
    (List.map String.trim lines)

let wsl2 args =
  let open Bos in
  Logs.info (fun l -> l "wsl %a" (Fmt.list ~sep:Fmt.sp Fmt.string) args);
  OS.Cmd.run Cmd.(v "wsl" %% of_list args) |> rmsg

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
  match (opts.next, opts.fetch_siblings) with
  | _, true ->
      (sib "dksdk-cmake") env
      |> sib "dksdk-ffi-c" |> sib "dksdk-ffi-java" |> sib "dksdk-ffi-ocaml"
  | true, false ->
      (* Setting just the branch means dksdk-access can read repository.ini
         and add the authentication token. *)
      Bos.OSEnvMap.(
        add "DKSDK_CMAKE_BRANCH_1_0" "next" env
        |> add "DKSDK_FFI_C_BRANCH_1_0" "next"
        |> add "DKSDK_FFI_JAVA_BRANCH_1_0" "next"
        |> add "DKSDK_FFI_OCAML_BRANCH_1_0" "next")
  | false, false -> env
