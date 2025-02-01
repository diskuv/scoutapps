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

let run ?debug_env ?env ~projectdir ~name ~slots args =
  let tools_dir = Fpath.(projectdir / ".tools") in
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
      let vsstudio_dir = Slots.vsdir_exn slots in
      let quoted_cmdargs =
        Fpath.to_string cmake :: args |> List.map Filename.quote
      in
      let with_vsdev = Fpath.(tools_dir / Printf.sprintf "vsdev-%s.ps1" name) in
      let _ =
        Bos.OS.File.write with_vsdev
          (Fmt.str
             {|
# https://github.com/microsoft/terminal/issues/280#issuecomment-1728298632
# This happens in Windows Sandbox which starts in Consolas font.
# (also see run-ps1.cmd)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ErrorActionPreference='Stop';

# Clear out any parent VsDev/vcvarsall environment variables. We only want
# the `-VsInstallPath <installation>` selected.
Function Remove-EnvItem {
    param ( [string]$Name )
    if (Test-Path "$Name") {
      Remove-Item "$Name"
    }
}
Remove-EnvItem Env:__devinit_path
Remove-EnvItem Env:__VCVARS_REDIST_VERSION
Remove-EnvItem Env:__VSCMD_PREINIT_PATH
Remove-EnvItem Env:__VSCMD_PREINIT_VCToolsVersion
Remove-EnvItem Env:DevEnvDir
Remove-EnvItem Env:EXTERNAL_INCLUDE
Remove-EnvItem Env:INCLUDE
Remove-EnvItem Env:LIB
Remove-EnvItem Env:LIBPATH
Remove-EnvItem Env:VCIDEInstallDir
Remove-EnvItem Env:VCINSTALLDIR
Remove-EnvItem Env:VCToolsInstallDir
Remove-EnvItem Env:VCToolsRedistDir
Remove-EnvItem Env:VCToolsVersion
Remove-EnvItem Env:VS160COMNTOOLS
Remove-EnvItem Env:VS170COMNTOOLS
Remove-EnvItem Env:VSCMD_ARG_app_plat
Remove-EnvItem Env:VSCMD_ARG_HOST_ARCH
Remove-EnvItem Env:VSCMD_ARG_TGT_ARCH
Remove-EnvItem Env:VSCMD_DEBUG
Remove-EnvItem Env:VSCMD_VER
Remove-EnvItem Env:VSINSTALLDIR

Import-Module '%a\Common7\Tools\Microsoft.VisualStudio.DevShell.dll';
Enter-VsDevShell -VsInstallPath '%a' -DevCmdArguments '-arch=amd64';
& %s;
exit $LASTEXITCODE|}
             Fpath.pp vsstudio_dir Fpath.pp vsstudio_dir
             (String.concat " " quoted_cmdargs))
        |> rmsg
      in
      let run_ps1 = Filename.concat (Tr1Assets.LocalDir.v ()) "run-ps1.cmd" in
      Bos.Cmd.(v run_ps1 % p with_vsdev)
    else Bos.Cmd.(v (p cmake) %% of_list args)
  in

  (* Run *)
  (match debug_env with
  | Some () ->
      OSEnvMap.fold
        (fun k v () ->
          Logs.debug (fun l -> l "Environment for CMake: %s=%s" k v))
        env ()
  | None -> ());
  let env = Utils.slot_env ~env ~slots () in
  Logs.info (fun l -> l "%a" Cmd.pp cmd);
  OS.Dir.with_current projectdir (fun () -> OS.Cmd.run ~env cmd |> rmsg) ()
  |> rmsg
