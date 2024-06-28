(* TODO: Make this a DkCoder "us" script. *)

open Bos

(* Ported from Utils since this script is standalone. *)
let rmsg = function Ok v -> v | Error (`Msg msg) -> failwith msg

let run ?debug_env ?env ~projectdir ~builddir args =
  let env =
    match env with Some env -> env | None -> OS.Env.current () |> rmsg
  in

  let cpack = Fpath.(projectdir / ".ci" / "cmake" / "bin" / "cpack") in

  let cmd = Cmd.(v (p cpack) %% of_list args) in

  (* Run *)
  (match debug_env with
  | Some () ->
      OSEnvMap.fold
        (fun k v () ->
          Logs.debug (fun l -> l "Environment for CPack: %s=%s" k v))
        env ()
  | None -> ());
  Logs.info (fun l -> l "%a" Cmd.pp cmd);
  OS.Dir.with_current builddir (fun () -> OS.Cmd.run ~env cmd |> rmsg) ()
  |> rmsg
