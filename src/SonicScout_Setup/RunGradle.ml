(* TODO: Make this a DkCoder "us" script.

   REPLACES: dksdk.gradle.run and dksdk.android.gradle.configure.

   FIXES BUGS:
   1. `./dk dksdk.gradle.run` would inject OCaml environment and mess up Android Gradle Plugin.
   2. `./dk dksdk.android.gradle.configure` had a chicken-and-egg problem with valid/invalid cmake.dir.

   PREREQS (must be replaced before dksdk.gradle.run is replaced):
   1. `./dk dksdk.java.jdk.download NO_SYSTEM_PATH JDK 17`
   2. `./dk dksdk.gradle.download ALL NO_SYSTEM_PATH`
   3. `./dk dksdk.android.gradle.configure [OVERWRITE]`
*)

open Bos

(* Ported from Utils since this script is standalone. *)
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

(** Mimic the escaping done by Android Studio itself.

    Example:

    {v
     sdk.dir=Y\:\\source\\dksdk-ffi-java\\.ci\\local\\share\\android-sdk
     cmake.dir=C\:/Users/beckf/AppData/Local/Programs/DkSDK/dkcoder/cmake-3.25.3-windows-x86_64
    v}

    So backslashes and colons are escaped. *)
let android_local_properties_escape s =
  Stringext.replace_all s ~pattern:"\\" ~with_:"\\\\"
  |> Stringext.replace_all ~pattern:":" ~with_:"\\:"

let forward_slash p =
  Stringext.replace_all ~pattern:"\\" ~with_:"/" (Fpath.to_string p)

(** [generate_local_properties] creates a ["local.properties"].

    On Windows it will create the properties file without a ["cmake.dir"] property,
    and then run a Gradle target to download a ["cmake.exe"] proxy for WSL2,
    and then recreate the properties file with a ["cmake.dir"] property
    referencing the WSL2 cmake.exe proxy.
    
    On non-Windows systems, the final properties file is written immediately.
    
    If you don't use this, you are subject to a chicken-and-egg problem
    on Windows. When you open Android Studio and
    ["cmake.dir" = "...//dkconfig/build/emulators/dksdk-wsl2/cmake.dir"] you
    get:
       org.gradle.api.ProjectConfigurationException: A problem occurred configuring project ':data'.
       Caused by: java.lang.NullPointerException
       at com.android.build.gradle.internal.cxx.settings.CxxAbiModelSettingsRewriterKt.calculateConfigurationHash(CxxAbiModelSettingsRewriter.kt:226)
    if there is no ["bin/cmake.exe"] in the cmake.dir folder.
    However, a Gradle task needs to run to generate that ["bin/cmake.exe"].
    So the two-step procedure this function follows leaves Gradle in a good
    state.

    Because ["bin/cmake.exe"] is an output of a Gradle task, it is deleted
    at arbitrary times by Android Gradle (ex. during a clean). {b Always} call
    this function to mitigate the deletion. *)
let rec generate_local_properties ~projectdir () =
  (* keep the directories forward-slashed so readable *)
  let sdk_dir =
    forward_slash Fpath.(projectdir / ".ci" / "local" / "share" / "android-sdk")
  in
  let local_properties = Fpath.(projectdir / "local.properties") in
  let content ~cmake_dir =
    [
      "# Generated by DkSDK RunGradle script";
      Fmt.str "sdk.dir=%s" (android_local_properties_escape sdk_dir);
      Fmt.str "cmake.dir=%s"
        (android_local_properties_escape (forward_slash cmake_dir));
    ]
  in
  let cmake_3_25_3_home =
    match Sys.getenv_opt "DKCODER_CMAKE_EXE" with
    | Some cmake_exe -> Fpath.(v cmake_exe |> parent |> parent)
    | None ->
        failwith
          "Expected to be run within DkCoder. But no DKCODER_CMAKE_EXE \
           environment variable was available."
  in
  (* If dkconfig is present and we are on Windows we assume WSL2 proxy will
       be used. *)
  let dkconfig = Fpath.(projectdir / "dkconfig") in
  if Sys.win32 && OS.Dir.exists dkconfig |> rmsg then begin
    (* WSL2 proxy is used. So find a native Windows cmake.exe 3.25.3
       (must specify exact versions with Android Gradle Plugin!).

       We can either place the native cmake.exe in the PATH or
       modify the local.properties cmake.dir property. Since we
       already must write the local.properties to ensure that a
       previous but now invalid cmake.dir is not present, we choose
       to set a new cmake.dir property here (always!). *)
    let emulators = Fpath.(dkconfig / "build" / "emulators") in
    let cmake_wsl2_home = Fpath.(emulators / "dksdk-wsl2" / "cmake.dir") in
    let cmake_exe = Fpath.(cmake_wsl2_home / "bin" / "cmake.exe") in
    if not (OS.File.exists cmake_exe |> rmsg) then (
      Logs.info (fun l -> l "Downloading WSL2 proxy %a" Fpath.pp cmake_exe);
      (* Deleting cmake-ndk.json is insurance that the Gradle task is rerun. *)
      OS.File.delete Fpath.(emulators / "cmake-ndk.json") |> rmsg;
      OS.File.write_lines local_properties
        (content ~cmake_dir:cmake_3_25_3_home)
      |> rmsg;
      run ~stopcycle:() ~projectdir [ ":dkconfig:dksdkCmakeNdkEmulator" ]);
    (* Now use WSL2 proxy as cmake.dir *)
    OS.File.write_lines local_properties (content ~cmake_dir:cmake_wsl2_home)
    |> rmsg
  end
  else begin
    OS.File.write_lines local_properties (content ~cmake_dir:cmake_3_25_3_home)
    |> rmsg
  end

and run ?stopcycle ?env ?debug_env ~projectdir args =
  let env =
    match env with Some env -> env | None -> OS.Env.current () |> rmsg
  in

  (* Don't leak DkCoder OCaml environment to Android Gradle Plugin. *)
  let env = remove_ocaml_dkcoder_env env in

  (* Add JAVA_HOME and Java to PATH *)
  let env = add_java_env ~projectdir env in

  (* Find Gradle *)
  let gradle = find_gradle_binary ~projectdir in

  (* Ensure a valid local.properties *)
  (match stopcycle with
  | None -> generate_local_properties ~projectdir ()
  | Some () -> ());

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
