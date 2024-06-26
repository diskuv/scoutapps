(* TODO: Make this a DkCoder "us" script.

   REPLACES: dksdk.gradle.run.

   FIXES BUGS:
   1. `./dk dksdk.gradle.run` would inject OCaml environment and mess up Android Gradle Plugin.

   PREREQS (must be replaced before dksdk.gradle.run is replaced):
   1. `./dk dksdk.java.jdk.download NO_SYSTEM_PATH JDK 17`
   2. `./dk dksdk.gradle.download ALL NO_SYSTEM_PATH`
   3. `./dk dksdk.android.gradle.configure [OVERWRITE]`
*)

open Bos

let rmsg = function Ok v -> v | Error (`Msg msg) -> failwith msg

(** Don't leak DkCoder OCaml environment to Android Gradle Plugin which will infect DkSDK CMake
    host detection of OCaml (`ocamlc -where` in dksdk-cmake/.../115-ocaml-config).
    In fact, don't leak any existing OCaml environment. *)
let remove_ocaml_dkcoder_env env =
  let env =
    OSEnvMap.(
      remove "OPAMROOT" env
      |> remove "OPAM_SWITCH_PREFIX"
      |> remove "CAML_LD_LIBRARY_PATH"
      |> remove "OPAM_LAST_ENV"
      |> remove "OCAML_TOPLEVEL_PATH"
      |> remove "OCAMLRUNPARAM" |> remove "OCAMLLIB")
  in
  (* Also remove DkCoder from the PATH *)
  let open OSEnvMap in
  match
    (Sys.getenv_opt "PATH", Sys.getenv_opt "DKCODER_HELPERS", Sys.win32)
  with
  | Some path, Some helpers, true when helpers <> "" ->
      remove "PATH" env
      |> add "PATH"
           (Stringext.replace_all path ~pattern:(helpers ^ ";") ~with_:""
           |> Stringext.replace_all ~pattern:(helpers ^ "\\stublibs;") ~with_:""
           )
  | Some path, Some helpers, false when helpers <> "" ->
      remove "PATH" env
      |> add "PATH"
           (Stringext.replace_all path ~pattern:(helpers ^ ":") ~with_:""
           |> Stringext.replace_all ~pattern:(helpers ^ "/stublibs:") ~with_:""
           )
  | _ -> env

let find_java_home ~projectdir =
  let java_home_opt =
    let home =
      Fpath.(
        projectdir / ".ci" / "local" / "share" / "jdk" / "Contents" / "Home")
    in
    if OS.File.exists Fpath.(home / "bin" / "javac") |> rmsg then Some home
    else
      let home = Fpath.(projectdir / ".ci" / "local" / "share" / "jdk") in
      if Sys.win32 && OS.File.exists Fpath.(home / "bin" / "javac.exe") |> rmsg
      then Some home
      else if
        (not Sys.win32) && OS.File.exists Fpath.(home / "bin" / "javac") |> rmsg
      then Some home
      else None
  in
  match java_home_opt with
  | Some h -> h
  | None ->
      failwith
        "No local JAVA_HOME detected. Make sure that './dk \
         dksdk.java.jdk.download NO_SYSTEM_PATH JDK 17' has been run."

let add_java_env ~projectdir env =
  (* Add JAVA_HOME *)
  let java_home = find_java_home ~projectdir in
  let env = OSEnvMap.(add "JAVA_HOME" (Fpath.to_string java_home) env) in

  (* Gradle jvmToolchain detection has problems if the Java
     is not in the PATH.
     https://github.com/ankidroid/Anki-Android/issues/13340#issuecomment-1445218572 *)
  let java_bin = Fpath.(java_home / "bin") |> Fpath.to_string in
  OSEnvMap.(
    update "PATH"
      (function
        | None -> Some java_bin
        | Some path ->
            Some
              (if Sys.win32 then java_bin ^ ";" ^ path
               else java_bin ^ ":" ^ path))
      env)

let find_gradle_binary ~projectdir =
  let binary_opt =
    let home = Fpath.(projectdir / ".ci" / "local" / "share" / "gradle") in
    if Sys.win32 && OS.File.exists Fpath.(home / "bin" / "gradle.bat") |> rmsg
    then Some Fpath.(home / "bin" / "gradle.bat")
    else if
      (not Sys.win32) && OS.File.exists Fpath.(home / "bin" / "gradle") |> rmsg
    then Some Fpath.(home / "bin" / "gradle")
    else None
  in
  match binary_opt with
  | Some b -> b
  | None ->
      failwith
        "No local Gradle detected. Make sure that './dk dksdk.gradle.download \
         ALL NO_SYSTEM_PATH' has been run."

let run ?env ?debug_env ~projectdir args =
  let env =
    match env with Some env -> env | None -> OS.Env.current () |> rmsg
  in

  (* Don't leak DkCoder OCaml environment to Android Gradle Plugin. *)
  let env = remove_ocaml_dkcoder_env env in

  (* Add JAVA_HOME and Java to PATH *)
  let env = add_java_env ~projectdir env in

  (* Find Gradle *)
  let gradle = find_gradle_binary ~projectdir in

  (* Run *)
  (match debug_env with
  | Some () ->
      OSEnvMap.fold
        (fun k v () ->
          Logs.debug (fun l -> l "Environment for Gradle: %s=%s" k v))
        env ()
  | None -> ());
  Logs.info (fun l ->
      l "%a %a" Fpath.pp gradle (Fmt.list ~sep:Fmt.sp Fmt.string) args);
  OS.Dir.with_current projectdir
    (fun () -> OS.Cmd.run ~env Cmd.(v (p gradle) %% of_list args) |> rmsg)
    ()
  |> rmsg
