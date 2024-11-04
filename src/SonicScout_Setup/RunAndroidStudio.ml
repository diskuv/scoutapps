(* TODO: Make this a DkCoder "us" script.

   REPLACES: dksdk.android.studio.run.

   FIXES BUGS:
   1. `./dk dksdk.android.studio.run` would inject OCaml environment and mess up Android Gradle Plugin.

   PREREQS (must be replaced before dksdk.android.studio.run is replaced):
   1. `./dk dksdk.java.jdk.download NO_SYSTEM_PATH JDK 17`
   2. `./dk dksdk.gradle.download ALL NO_SYSTEM_PATH`
   3. `./dk dksdk.android.gradle.configure [OVERWRITE]`
   3. `./dk dksdk.android.studio.download NO_SYSTEM_PATH`
*)

open Bos

let find_studio_binary ~projectdir =
  let binary_opt =
    let studio_app_bin =
      Fpath.(
        projectdir / ".ci" / "local" / "share" / "Android Studio.app"
        / "Contents" / "MacOS" / "studio")
    in
    Logs.debug (fun l -> l "Checking for macOS at %a" Fpath.pp studio_app_bin);
    if OS.File.exists studio_app_bin |> RunGradle.rmsg then Some studio_app_bin
    else
      let home =
        Fpath.(projectdir / ".ci" / "local" / "share" / "android-studio")
      in
      Logs.debug (fun l -> l "Checking for Linux/Windows in %a" Fpath.pp home);
      if Sys.win32 then
        if OS.File.exists Fpath.(home / "bin" / "studio.bat") |> RunGradle.rmsg
        then Some Fpath.(home / "bin" / "studio.bat")
        else None
      else if OS.File.exists Fpath.(home / "bin" / "studio") |> RunGradle.rmsg
      then Some Fpath.(home / "bin" / "studio")
      else if
        OS.File.exists Fpath.(home / "bin" / "studio.sh") |> RunGradle.rmsg
      then Some Fpath.(home / "bin" / "studio.sh")
      else None
  in

  match binary_opt with
  | Some b -> b
  | None ->
      failwith
        "No local Gradle detected. Make sure that './dk \
         dksdk.android.studio.download NO_SYSTEM_PATH' has been run."

let run ?env ?debug_env ~projectdir args =
  let env =
    match env with
    | Some env -> env
    | None -> OS.Env.current () |> RunGradle.rmsg
  in

  (* Don't leak DkCoder OCaml environment to Android Gradle Plugin. *)
  let env = RunGradle.remove_ocaml_dkcoder_env env in

  (* Add JAVA_HOME and Java to PATH (not part of original `dksdk.android.studio.run`) *)
  let env = RunGradle.add_java_env ~projectdir env in

  (* Add Ninja to PATH (not part of original `dksdk.android.studio.run`).
     Fixes: [CXX1416] Could not find Ninja on PATH or in SDK CMake bin folders. *)
  let env = RunGradle.add_ninja_env ~projectdir env in

  (* Find Android Studio *)
  let studio = find_studio_binary ~projectdir in

  (* Generate a valid local.properties *)
  RunGradle.generate_local_properties ~projectdir ();

  (* Run *)
  (match debug_env with
  | Some () ->
      OSEnvMap.fold
        (fun k v () ->
          Logs.debug (fun l -> l "Environment for Android Studio: %s=%s" k v))
        env ()
  | None -> ());
  Logs.info (fun l ->
      l "%a %a" Fpath.pp studio (Fmt.list ~sep:Fmt.sp Fmt.string) args);
  OS.Dir.with_current projectdir
    (fun () ->
      OS.Cmd.run ~env Cmd.(v (p studio) %% of_list args) |> RunGradle.rmsg)
    ()
  |> RunGradle.rmsg
