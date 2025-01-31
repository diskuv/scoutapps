(** https://download.qt.io/online/qtsdkrepository/windows_x86/desktop/qt5_5152/Updates.xml *)
let qt_ver, qt_downloadver, qt_updatever =
  ("5.15.2", "qt5_5152", "5.15.2-0-202011130602")

let clean areas =
  let open Bos in
  let cwd = OS.Dir.current () |> Utils.rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in
  if List.mem `QtInstallation areas then begin
    Utils.start_step "Cleaning SonicScoutBackend Qt installation";
    DkFs_C99.Path.rm ~recurse:() ~force:() ~kill:()
      Fpath.[ projectdir / qt_ver ]
    |> Utils.rmsg
  end

let tools_dir ~projectdir = Fpath.(projectdir / ".tools")

type qt_locations = {
  aqt_host : string;
  aqt_target : string;  (** [aqt_target] is the `aqt` target to download  *)
  aqt_subdir : string;
      (** [aqt_subdir] is the subdirectory under the QT5 version {!qt_ver}  *)
  qt_ver : string;
  qt_abi : string;
      (** [qt_abi] is the ["windows_x86"] in ["https://download.qt.io/online/qtsdkrepository/windows_x86/desktop/qt5_5152/Updates.xml"] *)
  qt_downloadver : string;
      (** [qt_downloadver] is the ["qt5_5152"] in ["https://download.qt.io/online/qtsdkrepository/windows_x86/desktop/qt5_5152/Updates.xml"] *)
  qt_updatever : string;
      (** [qt_updatever] is the ["5.15.2-0-202011130602"] in ["<Version>5.15.2-0-202011130602</Version>"] of the ["Updates.xml"]. *)
}

let qt_locations ?host_abi () =
  let aqt_host, aqt_target, aqt_subdir =
    match Option.value host_abi ~default:Tr1HostMachine.abi with
    | `darwin_x86_64 | `darwin_arm64 -> ("mac", "clang_64", "clang_64")
    | `windows_x86_64 | `windows_x86 ->
        ("windows", "win64_msvc2019_64", "msvc2019_64")
    | `linux_x86_64 -> ("linux", "gcc_64", "gcc_64")
    | _ ->
        failwith "Currently your host machine is not supported by Sonic Scout"
  in
  let qt_abi =
    (* https://github.com/miurahr/aqtinstall/blob/7917b2d725f56e8ceb6ba17b41ea0571506c7320/aqt/archives.py#L408-L421 *)
    (* http://mirrors.ocf.berkeley.edu/qt/online/qtsdkrepository/ *)
    match Tr1HostMachine.abi with
    | `android_arm32v7a | `android_arm64v8a | `android_x86 | `android_x86_64 ->
        "all_os"
    | `darwin_x86_64 | `darwin_arm64 -> "mac_x64"
    | `windows_x86_64 | `windows_x86 -> "windows_x86"
    | `windows_arm64 -> "windows_arm64"
    | `linux_x86_64 -> "linux_x64"
    | `linux_arm64 -> "linux_arm64"
    | _ ->
        failwith "Currently your host machine is not supported by Sonic Scout"
  in
  {
    aqt_host;
    aqt_target;
    aqt_subdir;
    qt_abi;
    qt_ver;
    qt_downloadver;
    qt_updatever;
  }

let sha256_and_sha1_file file =
  let ctx256 = ref (Digestif.SHA256.init ()) in
  let ctx1 = ref (Digestif.SHA1.init ()) in
  Bos.OS.File.with_input ~bytes:(Bytes.create 32_768) file
    (fun f () ->
      let rec feedloop = function
        | Some (b, pos, len) ->
            ctx256 := Digestif.SHA256.feed_bytes !ctx256 ~off:pos ~len b;
            ctx1 := Digestif.SHA1.feed_bytes !ctx1 ~off:pos ~len b;
            feedloop (f ())
        | None -> (Digestif.SHA256.get !ctx256, Digestif.SHA1.get !ctx1)
      in
      feedloop (f ()))
    ()

(** Subdirectories (called "addons" in Qt6) of https://qtproject.mirror.liquidtelecom.com/online/qtsdkrepository/windows_x86/desktop/qt5_5152/
    that are not in the base directory
    https://qtproject.mirror.liquidtelecom.com/online/qtsdkrepository/windows_x86/desktop/qt5_5152/qt.qt5.5152.win64_msvc2019_64/
    
    See https://doc.qt.io/qt-6/qtmodules.html and
    https://aqtinstall.readthedocs.io/en/latest/getting_started.html#installing-a-subset-of-qt-archives-advanced *)
let qt_nonbase_modules =
  [
    "qtcharts";
    "qtdatavis3d";
    "qtlottie";
    "qtnetworkauth";
    "qtpurchasing";
    "qtquick3d";
    "qtquicktimeline";
    "qtscript";
    "qtvirtualkeyboard";
    "qtwebengine";
    "qtwebglplugin";
  ]

let show_asset_spec_contents ~archives_dir ~qt_abi ~qt_downloadver ~qt_updatever
    ~aqt_target =
  let open Bos in
  let f_contents fpath acc =
    let basename = Fpath.basename fpath in
    (* https://github.com/miurahr/aqtinstall/blob/7917b2d725f56e8ceb6ba17b41ea0571506c7320/aqt/archives.py#L492-L499 *)
    (* Example base:
       https://qtproject.mirror.liquidtelecom.com/online/qtsdkrepository/windows_x86/desktop/qt5_5152/qt.qt5.5152.win64_msvc2019_64/5.15.2-0-202011130602qtconnectivity-Windows-Windows_10-MSVC2019-Windows-Windows_10-X86_64.7z *)
    (* Example nonbase:
       https://qtproject.mirror.liquidtelecom.com/online/qtsdkrepository/windows_x86/desktop/qt5_5152/qt.qt5.5152.qtwebengine.win64_msvc2019_64/5.15.2-0-202011130602qtwebengine-Windows-Windows_10-MSVC2019-Windows-Windows_10-X86_64.7z *)
    let nonbase =
      List.find_map
        (fun nonbase_module ->
          if String.starts_with basename ~prefix:(nonbase_module ^ "-") then
            Some nonbase_module
          else None)
        qt_nonbase_modules
    in
    (* Example debuginfo:
       https://qtproject.mirror.liquidtelecom.com/online/qtsdkrepository/windows_x86/desktop/qt5_5152/qt.qt5.5152.debug_info.win64_msvc2019_64/5.15.2-0-202011130602qt3d-Windows-Windows_10-MSVC2019-Windows-Windows_10-X86_64-debug-symbols.7z *)
    let debuginfo = String.ends_with basename ~suffix:"-debug-symbols.7z" in
    let archive_path =
      (* qt5_5152 -> qt5.5152 *)
      let qt_download_ver_dot =
        Stringext.replace_all qt_downloadver ~pattern:"_" ~with_:"."
      in
      (* qt.qt5.5152.win64_msvc2019_64 (base) or qt.qt5.5152.qtwebengine.win64_msvc2019_64 (nonbase) *)
      let qt_module =
        match (nonbase, debuginfo) with
        | _, true ->
            Printf.sprintf "qt.%s.debug_info.%s" qt_download_ver_dot aqt_target
        | Some nonbase_module, false ->
            Printf.sprintf "qt.%s.%s.%s" qt_download_ver_dot nonbase_module
              aqt_target
        | None, false ->
            Printf.sprintf "qt.%s.%s" qt_download_ver_dot aqt_target
      in
      Printf.sprintf "online/qtsdkrepository/%s/desktop/%s/%s/%s%s" qt_abi
        qt_downloadver qt_module qt_updatever basename
    in
    let sha256, sha1 =
      let s256, s1 = sha256_and_sha1_file fpath |> Utils.rmsg in
      (Digestif.SHA256.to_hex s256, Digestif.SHA1.to_hex s1)
    in
    let sha256_of_dot_sha1 =
      (* The content of a .sha1 file is the lowercase hex of the SHA1 __with no CR or LF__.
         Example: d59e7794267f0e42fd5d57f88c00c28fb86bc3a2 *)
      let contents = sha1 in
      Digestif.SHA256.(to_hex (digest_string contents))
    in
    let sha256_of_dot_sha256 =
      (* The content of a .sha256 file is the lowercase hex of the SHA1 followed by two spaces and the basename(url), __with LF__.
         Example: 0dc63ca9bb91cb204d479356edb89b30e3599f1c0bce469b1dd5a339134f25e2  5.15.2-0-202011130602d3dcompiler_47-x64.7z *)
      let contents = sha256 ^ "  " ^ qt_updatever ^ basename ^ "\n" in
      Digestif.SHA256.(to_hex (digest_string contents))
    in
    `O
      [
        ("path_unencrypted", `String archive_path);
        ("checksum", `O [ ("sha256", `String sha256) ]);
      ]
    :: `O
         [
           ("path_unencrypted", `String (archive_path ^ ".sha1"));
           ("checksum", `O [ ("sha256", `String sha256_of_dot_sha1) ]);
         ]
    :: `O
         [
           ("path_unencrypted", `String (archive_path ^ ".sha256"));
           ("checksum", `O [ ("sha256", `String sha256_of_dot_sha256) ]);
         ]
    :: acc
  in
  let contents =
    OS.Dir.fold_contents
      ~elements:(`Sat (fun fpath -> Ok (Fpath.get_ext fpath = ".7z")))
      ~traverse:`None f_contents [] archives_dir
    |> Utils.rmsg
  in
  print_endline (Ezjsonm.to_string ~minify:false (`A contents))

let run ?create_asset_spec ?host_abi ~slots () =
  Utils.start_step "Installing Qt";
  let open Bos in
  let cwd = OS.Dir.current () |> Utils.rmsg in
  let projectdir = Fpath.(cwd / "us" / "SonicScoutBackend") in
  (* https://aqtinstall.readthedocs.io/en/latest/getting_started.html

     Cheatsheet:

     $ (source us/SonicScoutBackend/.tools/miniconda/bin/activate && conda run -n aqt aqt list-qt mac desktop --arch 5.15.2)
     clang_64 wasm_32
  *)
  let {
    aqt_host;
    aqt_target;
    aqt_subdir;
    qt_ver;
    qt_abi;
    qt_downloadver;
    qt_updatever;
  } =
    qt_locations ?host_abi ()
  in
  let qt5_dir = Fpath.(projectdir / qt_ver) in
  let archives_dir = Fpath.(qt5_dir / aqt_subdir / "archives") in
  if
    (not (OS.Dir.exists qt5_dir |> Utils.rmsg))
    || create_asset_spec = Some ()
       && not (OS.Dir.exists archives_dir |> Utils.rmsg)
  then begin
    Logs.info (fun l ->
        l "Installing Qt modules. This may take %s minutes ..."
          (if Sys.win32 then "several" else "a few"));
    Logs.info (fun l ->
        l
          "Debugging Qt downloads?@ Change 'level=INFO' to 'level=DEBUG' in@ \
           %a/environments-v1/*/*/Lib/site-packages/aqt/logging.ini"
          (Fmt.option Fpath.pp) (Slots.uv_cache slots));
    let python_version_args =
      match Slots.python_version slots with
      | None -> []
      | Some python_version -> [ "--python"; python_version ]
    in
    let archive_args =
      if create_asset_spec = Some () then
        (* https://aqtinstall.readthedocs.io/en/latest/configuration.html *)
        [ "--keep"; "--archive-dest"; Fpath.to_string archives_dir ]
      else []
    in
    Utils.uv_run ~exclude_newer:"2025-01-04T00:00:00Z" ~slots
      (python_version_args
      @ [
          "--no-project";
          "--with-requirements";
          Fpath.to_string
            Fpath.(projectdir / "dependencies" / "zxing" / "requirements.txt");
          "aqt";
          (* config: Use a Diskuv hosted mirror of Qt *)
          "--config";
          Filename.concat (Tr1Assets.LocalDir.v ()) "qt-settings.ini";
          "install-qt";
          "-O";
          Fpath.to_string projectdir;
          aqt_host;
          "desktop";
          qt_ver;
          aqt_target;
          "--modules";
          "all";
        ]
      @ archive_args)
  end;
  if create_asset_spec = Some () then
    show_asset_spec_contents ~archives_dir ~qt_abi ~qt_downloadver ~qt_updatever
      ~aqt_target

let __init () =
  if Array.length Sys.argv <= 1 then
    failwith
      (Printf.sprintf "usage: ./dk %s windows_x86_64|darwin_arm64|..."
         __MODULE_ID__);
  let host_abi =
    match Sys.argv.(1) with
    | "darwin_x86_64" -> `darwin_x86_64
    | "darwin_arm64" -> `darwin_arm64
    | "windows_x86_64" -> `windows_x86_64
    | "windows_x86" -> `windows_x86
    | "linux_x86_64" -> `linux_x86_64
    | "linux_x86" -> `linux_x86
    | _ ->
        failwith "Currently your host machine is not supported by Sonic Scout"
  in
  let slots = Slots.create () in
  let slots = Python.run ~slots () in
  run ~create_asset_spec:() ~host_abi ~slots ()
