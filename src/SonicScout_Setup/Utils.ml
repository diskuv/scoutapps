(** {1 Options} *)

type opts = { next : bool; fetch_siblings : bool }

let default_opts : opts = { next = false; fetch_siblings = false }

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
