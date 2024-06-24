open Utils

let run () =
  let open Bos in
  start_step "Building SonicScoutAndroid";
  let cwd = OS.Dir.current () |> rmsg in
  let dk args =
    Logs.info (fun l -> l "dk %a" (Fmt.list ~sep:Fmt.sp Fmt.string) args);
    OS.Cmd.run Cmd.(v "./dk" %% of_list args) |> rmsg
  in
  let git args =
    Logs.info (fun l -> l "git %a" (Fmt.list ~sep:Fmt.sp Fmt.string) args);
    OS.Cmd.run Cmd.(v "git" %% of_list args) |> rmsg
  in
  OS.Dir.with_current
    Fpath.(cwd / "us" / "SonicScoutAndroid")
    (fun () ->
      dk [ "dksdk.project.get" ];
      dk [ "dksdk.cmake.link"; "QUIET" ];
      (* You can ignore the error if you got 'failed to create symbolic link' for dksdk.ninja.link *)
      dk [ "dksdk.ninja.link"; "QUIET" ];
      dk [ "dksdk.java.jdk.download"; "NO_SYSTEM_PATH" ];
      (* dk [ "dksdk.gradle.download"; "ALL"; "NO_SYSTEM_PATH" ];
      dk [ "dksdk.android.ndk.download"; "NO_SYSTEM_PATH" ];
      dk [ "dksdk.android.gradle.configure"; "OVERWRITE" ];
      git [ "-C"; "fetch/dksdk-ffi-java"; "clean"; "-d"; "-x"; "-f" ] *)
      ignore git
      
      )
    ()
  |> rmsg
