(** {1 Options} *)

type opts = { next : bool }

let default_opts : opts = { next = false }

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

(** {1 Running ./dk} *)

let dk ?env args =
  let open Bos in
  Logs.info (fun l -> l "./dk %a" (Fmt.list ~sep:Fmt.sp Fmt.string) args);
  let script = if Sys.win32 then Cmd.v ".\\dk.cmd" else Cmd.v "./dk" in
  OS.Cmd.run ?env Cmd.(script %% of_list args) |> rmsg

let dk_env ?(opts = default_opts) () =
  let env = Bos.OS.Env.current () |> rmsg in
  match opts.next with
  | true ->
      Bos.OSEnvMap.(
        add "DKSDK_CMAKE_REPO_1_0"
          "https://gitlab.com/diskuv/distributions/1.0/dksdk-cmake.git#next" env
        |> add "DKSDK_FFI_C_REPO_1_0"
             "https://gitlab.com/diskuv/distributions/1.0/dksdk-ffi-c.git#next"
        |> add "DKSDK_FFI_JAVA_REPO_1_0"
             "https://gitlab.com/diskuv/distributions/1.0/dksdk-ffi-java.git#next"
        |> add "DKSDK_FFI_OCAML_REPO_1_0"
             "https://gitlab.com/diskuv/distributions/1.0/dksdk-ffi-ocaml.git#next")
  | false -> env
