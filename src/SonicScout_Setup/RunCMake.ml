(* TODO: Make this a DkCoder "us" script.

   REPLACES: Legacy ./dk that runs CMake scripts.

   FIXES BUGS:
   1. `./dk` would inject OCaml environment and mess up direct CMake invocations.

   PREREQS (must be replaced before dksdk.gradle.run is replaced):
   1. `./dk` and `./dk.cmd` and `__dk.cmake`
*)

open Bos

(* Ported from Utils since this script is standalone. *)
let rmsg = function Ok v -> v | Error (`Msg msg) -> failwith msg

let run ?debug_env ?env ~projectdir args =
  let env =
    match env with Some env -> env | None -> OS.Env.current () |> rmsg
  in

  (* Don't leak DkCoder OCaml environment to Android Gradle Plugin. *)
  let env = RunGradle.remove_ocaml_dkcoder_env env in

  let cmake = Fpath.(projectdir / ".ci" / "cmake" / "bin" / "cmake") in

  (* Run *)
  (match debug_env with
  | Some () ->
      OSEnvMap.fold
        (fun k v () ->
          Logs.debug (fun l -> l "Environment for CMake: %s=%s" k v))
        env ()
  | None -> ());
  Logs.info (fun l ->
      l "%a %a" Fpath.pp cmake (Fmt.list ~sep:Fmt.sp Fmt.string) args);
  OS.Dir.with_current projectdir
    (fun () -> OS.Cmd.run ~env Cmd.(v (p cmake) %% of_list args) |> rmsg)
    ()
  |> rmsg
