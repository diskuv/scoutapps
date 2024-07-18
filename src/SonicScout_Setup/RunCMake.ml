(* TODO: Make this a DkCoder "us" script.

   REPLACES: Legacy ./dk that runs CMake scripts.

   FIXES BUGS:
   1. `./dk` would inject OCaml environment and mess up direct CMake invocations.
   2. Using Ninja with Visual Studio requires that you launch the Visual
      Studio Command Prompt (or vsdevcmd/vcvars). That is burdensome for the user.
      Confer: https://discourse.cmake.org/t/best-practice-for-ninja-build-visual-studio/4653/6

   PREREQS (must be replaced before dksdk.gradle.run is replaced):
   1. `./dk` and `./dk.cmd` and `__dk.cmake`
*)

open Bos

(* Ported from Utils since this script is standalone. *)
let rmsg = function Ok v -> v | Error (`Msg msg) -> failwith msg

let run ?debug_env ?env ?global_dkml ~projectdir args =
  let env =
    match env with Some env -> env | None -> OS.Env.current () |> rmsg
  in

  (* Don't leak DkCoder OCaml environment to Android Gradle Plugin. *)
  let env = RunGradle.remove_ocaml_dkcoder_env env in

  let cmake = Fpath.(projectdir / ".ci" / "cmake" / "bin" / "cmake") in

  let cmd =
    if Sys.win32 then
      (* Ninja requires that Visual Studio is already in the environment.
         Confer: https://discourse.cmake.org/t/best-practice-for-ninja-build-visual-studio/4653/6.

         Could use PowerShell to avoid writing a temporary Command Prompt vcvars/vsdev launch script.

           Import-Module C:\VS\Common7\Tools\Microsoft.VisualStudio.DevShell.dll;
           Enter-VsDevShell -VsInstallPath C:\VS -DevCmdArguments "-arch=amd64"

         Confer:
           https://learn.microsoft.com/en-us/visualstudio/ide/reference/command-prompt-powershell?view=vs-2022
           https://devblogs.microsoft.com/visualstudio/say-hello-to-the-new-visual-studio-terminal/ *)
      let vsstudio_dir =
        match global_dkml with
        | Some () ->
            OS.File.read
              Fpath.(
                v (Sys.getenv "LOCALAPPDATA")
                / "Programs" / "DkML" / "vsstudio.dir.txt")
            |> rmsg |> String.trim |> Fpath.v
        | None -> Fpath.v "C:/VS"
      in
      let quoted_cmdargs =
        Fpath.to_string cmake :: args |> List.map Filename.quote
      in
      Cmd.(
        v "powershell" % "-NoProfile" % "-ExecutionPolicy" % "Bypass"
        % "-Command"
        % Fmt.str
            "& { $ErrorActionPreference='Stop'; Import-Module \
             '%a\\Common7\\Tools\\Microsoft.VisualStudio.DevShell.dll'; \
             Enter-VsDevShell -VsInstallPath '%a' -DevCmdArguments \
             '-arch=amd64'; & %s; exit $LASTEXITCODE }"
            Fpath.pp vsstudio_dir Fpath.pp vsstudio_dir
            (String.concat " " quoted_cmdargs))
    else Cmd.(v (p cmake) %% of_list args)
  in

  (* Run *)
  (match debug_env with
  | Some () ->
      OSEnvMap.fold
        (fun k v () ->
          Logs.debug (fun l -> l "Environment for CMake: %s=%s" k v))
        env ()
  | None -> ());
  Logs.info (fun l -> l "%a" Cmd.pp cmd);
  OS.Dir.with_current projectdir (fun () -> OS.Cmd.run ~env cmd |> rmsg) ()
  |> rmsg
