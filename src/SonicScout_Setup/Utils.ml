exception StopProvisioning

let step = ref 1
let rmsg = function Ok v -> v | Error (`Msg msg) -> failwith msg

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

let dk ?env args =
  let open Bos in
  Logs.info (fun l -> l "./dk %a" (Fmt.list ~sep:Fmt.sp Fmt.string) args);
  let script = if Sys.win32 then Cmd.v ".\\dk.cmd" else Cmd.v "./dk" in
  OS.Cmd.run ?env Cmd.(script %% of_list args) |> rmsg

let dk_env ?next () =
  let env = Bos.OS.Env.current () |> rmsg in
  match next with
  | Some () ->
      Bos.OSEnvMap.(
        add "DKSDK_CMAKE_REPO_1_0"
          "https://gitlab.com/diskuv/distributions/1.0/dksdk-cmake.git#next" env
        |> add "DKSDK_FFI_C_REPO_1_0"
             "https://gitlab.com/diskuv/distributions/1.0/dksdk-ffi-c.git#next"
        |> add "DKSDK_FFI_JAVA_REPO_1_0"
             "https://gitlab.com/diskuv/distributions/1.0/dksdk-ffi-java.git#next"
        |> add "DKSDK_FFI_OCAML_REPO_1_0"
             "https://gitlab.com/diskuv/distributions/1.0/dksdk-ffi-ocaml.git#next")
  | None -> env

(* Clone of https://gitlab.com/diskuv/samples/dkcoder/DkHelloScript/-/blob/80efb164ea4d38f6156f30f69de19295cd635e29/src/DkHelloScript_Std/B55Http/B43Curl/B43Tiny.ml *)
let download uri ofile meth' =
  let module Curl = Cohttp_curl_lwt in
  let open Lwt.Syntax in
  Format.eprintf "Client with URI %s@." (Uri.to_string uri);
  let meth = Http.Method.of_string meth' in
  Format.eprintf "Client %s issued@." meth';
  let reply =
    let context = Curl.Context.create () in
    let request =
      Curl.Request.create ~timeout_ms:5000 meth ~uri:(Uri.to_string uri)
        ~input:Curl.Source.empty ~output:Curl.Sink.string
    in
    Curl.submit context request
  in
  let* resp, response_body =
    Lwt.both (Curl.Response.response reply) (Curl.Response.body reply)
  in
  Format.eprintf "response:%a@." Http.Response.pp resp;
  let status = Http.Response.status resp in
  Format.eprintf "Client %s returned: %a@." meth' Http.Status.pp status;
  (match status with
  | #Http.Status.success ->
      Format.eprintf "Status code was in the set 'success'@."
  | _ -> Format.eprintf "Status code was not in the set 'success'@.");
  let len = String.length response_body in
  Format.eprintf "Client body length: %d@." len;
  let output_body c = Lwt_io.write c response_body in
  match ofile with
  | None -> output_body Lwt_io.stdout
  | Some fname -> Lwt_io.with_file ~mode:Lwt_io.output fname output_body

(* Example [sum] from {{:https://github.com/mirage/digestif}digestif homepage}. *)
let cksum ~m ic =
  let module M = (val m : Digestif.S) in
  let tmp = Bytes.create 0x1000 in
  let rec go ctx =
    match In_channel.input ic tmp 0 0x1000 with
    | 0 -> M.get ctx
    | len ->
        let ctx = M.feed_bytes ctx ~off:0 ~len tmp in
        go ctx
    | exception End_of_file -> M.get ctx
  in
  go M.empty |> M.to_hex

let cksum_file ~m fp =
  Bos.OS.File.with_ic fp (fun ic () -> cksum ~m ic) () |> rmsg
