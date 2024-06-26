open Utils

let say_warning () =
  let rec ask () =
    StdIo.print_string
      {|
Android Studio will be downloaded and launched.

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
5. If you get a "Multiple Gradle daemons might be spawned because the Gradle
   JDK and JAVA_HOME locations are different." notification then you should
   click the "Select the Gradle JDK location". Choose the
   `ci/local/share/jdk` (or `ci/local/share/Android Studio App/Contents/jbr/Contents/Home`
   if on a macOS).

ONCE YOU HAVE FINISHED THE SETUP WIZARD, EXIT ANDROID STUDIO.

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

  say_warning ();
  dk [ "dksdk.android.studio.run"; "ARGS"; Fpath.to_string projectdir ]