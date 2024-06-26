open Utils

let say_warning () =
  let rec ask () =
    StdIo.print_string
      {|
Android Studio will be downloaded and launched.

SETUP WIZARD INSTRUCTIONS

1. The download step has a big 1GB download. DON'T BE SURPRISED IF IT TAKES
   10 MINUTES OR MORE.
2. If a "Trust and Open Project 'SonicScoutAndroid'" popup appears then
   enable "Trust projects in .../scoutapps/us" and then click the
   "Trust Project" button.
3. If a "Android SDK Manager" popup appears, click the button
   "Use Project's SDK".
4. When you first start Android Studio, take time to do the SETUP WIZARD:
      Import Settings? "No"
      Help Improve Android Studio? "Don't send"
      Install Type: "Standard"
      License Agreement: Accept

   If it complains about "Missing SDK" - "No Android SDK found", use "Next"
   to download it with all the default options selected.

BUILDING INSIDE ANDROID STUDIO

5. If you get a "Multiple Gradle daemons might be spawned because the Gradle
   JDK and JAVA_HOME locations are different." notification then you should
   click the "Select the Gradle JDK location". Choose the
   `ci/local/share/jdk` (or `ci/local/share/Android Studio App/Contents/jbr/Contents/Home`
   if on a macOS).
6. If Windows Firewall asks, you should GRANT ACCESS to "adb.exe". If you
   don't it is likely connecting to your Android devices will be difficult.
7. You will get very slow `Scanning index files`, `Loading symbols` and `Indexing` actions.
   To avoid these, right-click on any `\\wsl.localhost` based `build/DkSDKFiles` folders and
   **Mark Directory as Excluded**. That is shown on the picture:
   https://gitlab.com/diskuv/sonicscout/scoutapps/-/blob/main/us/SonicScoutAndroid/static/exclude-DkSDKFiles.png

Can you perform these steps? (y/N) |};
    StdIo.flush StdIo.stdout;
    try
      match StdIo.input_line StdIo.stdin with
      | "y" | "Y" -> ()
      | "n" | "N" -> raise StopProvisioning
      | "" -> raise StopProvisioning
      | _ -> ask ()
    with End_of_file ->
      StdIo.print_endline "<terminal or standard input closed> ... exiting";
      raise StopProvisioning
  in
  ask ()

let run () =
  let open Bos in
  start_step "Running Android Studio";
  let cwd = OS.Dir.current () |> rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutAndroid") in

  OS.Dir.with_current projectdir
    (fun () -> dk [ "dksdk.android.studio.download"; "NO_SYSTEM_PATH" ])
    ()
  |> rmsg;

  say_warning ();
  RunAndroidStudio.run ~debug_env:() ~projectdir []
