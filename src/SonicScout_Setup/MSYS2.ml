(* TODO: Make this a DkCoder "us" script.

   REPLACES: https://github.com/diskuv/dkml-component-unixutils/blob/d0a11eb120f70ba1b06eb1139001bac47045b4bd/src/installtime_enduser/windows/windows_install.ml
*)

(* Ported from Utils since this script is standalone. *)
let rmsg = function Ok v -> v | Error (`Msg msg) -> failwith msg

module Arg = Cmdliner.Arg
module Cmd = Cmdliner.Cmd
module Term = Cmdliner.Term

module Installer = struct
  open Bos

  let ( let* ) r f = match r with Ok v -> f v | Error (`Msg s) -> failwith s
  let ( let+ ) f x = Result.map x f

  type base = Base of string | No_base

  type download_msys2 = {
    msys2_estimated_sz : int;
    msys2_dkml_base_package_file : string;
    msys2_sha256 : string;
  }

  type select_msys2 =
    | Download_msys2 of download_msys2
    | Use_msys2_base_exe of Fpath.t

  type t = {
    (* The "base" installer is friendly for CI (ex. GitLab CI).
       The non-base installer will not work in CI. Will get exit code -1073741515 (0xFFFFFFFFC0000135)
       which is STATUS_DLL_NOT_FOUND; likely a graphical DLL is linked that is not present in headless
       Windows Server based CI systems. *)
    msys2_base : base;
    cache_dir : Fpath.t;
    target_sh : string option;
    target_msys2_dir : Fpath.t;
    select_msys2 : select_msys2;
  }

  let create ?bits32 ?msys2_base_exe ?target_sh ~target_msys2_dir ~cache_dir ()
      =
    let select_msys2 =
      match (msys2_base_exe, bits32) with
      | Some msys2_base_exe, _ -> Use_msys2_base_exe msys2_base_exe
      | _, Some () ->
          (* 32-bit *)
          Download_msys2
            {
              msys2_dkml_base_package_file = "65422464";
              msys2_estimated_sz = 64_950 * 1024;
              msys2_sha256 =
                "8a31ef2bcb0f3b9a820e15abe1d75bd1477577f9c218453377296e4f430693a0";
            }
      | _, None ->
          (* 64-bit *)
          Download_msys2
            {
              msys2_dkml_base_package_file = "65422459";
              msys2_estimated_sz = 76_240 * 1024;
              msys2_sha256 =
                "06977504e0a35b6662d952e59c26e730a191478ff99cb27b2b7886d6605ed787";
            }
    in
    {
      msys2_base =
        Base (match bits32 with Some () -> "msys32" | None -> "msys64");
      cache_dir;
      target_sh;
      target_msys2_dir;
      select_msys2;
    }

  let portable_delete_file target_fp =
    let ( let* ) = Result.bind in
    (* [doc from diskuvbox]
       [tracks https://github.com/dbuenzli/bos/issues/98]
       For Windows, can't write without turning off read-only flag.
       In fact, you can still get Permission Denied even after turning
       off read-only flag, perhaps because Windows has a richer
       permissions model than POSIX. So we remove the file
       after turning off read-only *)
    if Sys.win32 then
      let* exists = OS.File.exists target_fp in
      if exists then
        let* () = OS.Path.Mode.set target_fp 0o644 in
        OS.File.delete target_fp
      else Ok ()
    else OS.File.delete target_fp

  let download_file ~curl_exe ~url ~destfile expected_cksum estimated_sz =
    Logs.info (fun m -> m "Downloading %s" url);
    (* Write to a temporary file because, especially on 32-bit systems,
       the RAM to hold the file may overflow. And why waste memory on 64-bit?
       On Windows the temp file needs to be in the same directory as the
       destination file so that the subsequent rename succeeds.
    *)
    let destdir = Fpath.(normalize destfile |> split_base |> fst) in
    let* _already_exists = OS.Dir.create destdir in
    let* tmpfile = OS.File.tmp ~dir:destdir "curlo%s" in
    let protected () =
      let cmd =
        Cmd.(
          v (Fpath.to_string curl_exe)
          % "-L" % "-o" % Fpath.to_string tmpfile % url)
      in
      let* () = OS.Cmd.run cmd in
      (match Sys.backend_type with
      | Native | Other _ ->
          Logs.info (fun m -> m "Verifying checksum for %s" url)
      | Bytecode ->
          Logs.info (fun m ->
              m "Verifying checksum for %s using slow bytecode" url));
      let actual_cksum_ctx = ref (Digestif.SHA256.init ()) in
      let one_mb = 1_048_576 in
      let buflen = 32_768 in
      let buffer = Bytes.create buflen in
      let sofar = ref 0 in
      (* This will be piss slow with Digestif bytecode rather than Digestif.c.
         Or perhaps it is file reading; please hook up a profiler!
         TODO: Bundle in native code of digestif.c for both Win32 and Win64,
         or just spawn out to PowerShell `Get-FileHash -Algorithm SHA256`.
         Perhaps even make "sha256sum" be part of unixutils, with wrappers to
         shasum on macOS, sha256sum on Linux and Get-FileHash on Windows ...
         with this slow bytecode as fallback. *)
      let* actual_cksum =
        OS.File.with_input ~bytes:buffer tmpfile
          (fun f () ->
            let rec feedloop = function
              | Some (b, pos, len) ->
                  actual_cksum_ctx :=
                    Digestif.SHA256.feed_bytes !actual_cksum_ctx ~off:pos ~len b;
                  sofar := !sofar + buflen;
                  if !sofar mod one_mb = 0 then
                    Logs.info (fun l ->
                        l "Verified %d of %d MB" (!sofar / one_mb)
                          (estimated_sz / one_mb));
                  feedloop (f ())
              | None -> Digestif.SHA256.get !actual_cksum_ctx
            in
            feedloop (f ()))
          ()
      in
      if Digestif.SHA256.equal expected_cksum actual_cksum then
        Ok (Sys.rename (Fpath.to_string tmpfile) (Fpath.to_string destfile))
      else
        Error
          (`Msg
            (Fmt.str
               "Failed to verify the download '%s'. Expected SHA256 checksum \
                '%a' but got '%a'"
               url Digestif.SHA256.pp expected_cksum Digestif.SHA256.pp
               actual_cksum))
    in
    Fun.protect
      ~finally:(fun () ->
        match portable_delete_file tmpfile with
        | Ok () -> ()
        | Error (`Msg msg) ->
            (* Only WARN since this is inside a Fun.protect *)
            Logs.warn (fun l ->
                l "The temporary file %a could not be deleted: %s" Fpath.pp
                  tmpfile msg))
      (fun () -> protected ())

  (** [install_msys2 ~target_dir] installs MSYS2 into [target_dir] *)
  let install_msys2 { msys2_base; target_msys2_dir; cache_dir; select_msys2; _ }
      =
    (* Example: DELETE Z:\temp\prefix\tools\MSYS2 *)
    let* () =
      DkFs_C99.Path.rm ~force:() ~recurse:() ~kill:() [ target_msys2_dir ]
    in
    let* destfile =
      match select_msys2 with
      | Download_msys2
          { msys2_dkml_base_package_file; msys2_sha256; msys2_estimated_sz = _ }
        ->
          let destination = Fpath.(cache_dir / "msys2.exe") in
          let url =
            "https://gitlab.com/dkml/distributions/msys2-dkml-base/-/package_files/"
            ^ msys2_dkml_base_package_file ^ "/download"
          in
          let () =
            Lwt_main.run
            @@ DkNet_Std.Http.download_uri ~max_time_ms:300_000
                 ~checksum:(`SHA_256 msys2_sha256) ~destination
                 (Uri.of_string url)
          in
          Ok destination
      | Use_msys2_base_exe msys2_base_exe -> Ok msys2_base_exe
    in
    match msys2_base with
    | Base msys2_basename ->
        (* Example: Z:\temp\prefix\tools, MSYS2 *)
        let target_msys2_parent_fp, _target_msys2_rel_fp =
          Fpath.split_base target_msys2_dir
        in
        (* Example: Z:\temp\prefix\tools\msys64 *)
        let target_msys2_extract_fp =
          Fpath.(target_msys2_parent_fp / msys2_basename)
        in
        let* () =
          DkFs_C99.Path.rm ~force:() ~recurse:() ~kill:()
            [ target_msys2_extract_fp ]
        in
        let* () =
          OS.Cmd.run
            Cmd.(
              v (Fpath.to_string destfile)
              % "-y"
              % Fmt.str "-o%a" Fpath.pp target_msys2_parent_fp)
        in
        (* Example: MOVE Z:\temp\prefix\tools\msys64 -> Z:\temp\prefix\tools\MSYS2 *)
        OS.Path.move target_msys2_extract_fp target_msys2_dir
    | No_base ->
        OS.Cmd.run
          Cmd.(
            v (Fpath.to_string destfile)
            % "--silentUpdate" % "--verbose"
            % Fpath.to_string target_msys2_dir)

  (** [install_msys2_dll_in_targetdir ~msys2_dir ~target_dir] copies
      msys-2.0.dll into [target_dir] if it is not already in [target_dir] *)
  let install_msys2_dll_in_targetdir ~msys2_dir ~target_dir =
    let dest = Fpath.(target_dir / "msys-2.0.dll") in
    let* exists = OS.Path.exists dest in
    if exists then Ok ()
    else
      DkFs_C99.File.copy
        ~src:Fpath.(msys2_dir / "usr" / "bin" / "msys-2.0.dll")
        ~dest ()

  (** [install_trust_anchors ~msys2_dir ~trust_anchors] *)
  let install_trust_anchors ~msys2_dir ~trust_anchors =
    (* https://www.msys2.org/docs/faq/#how-can-i-make-msys2pacman-trust-my-companys-custom-tls-ca-certificate *)
    let* () =
      (* Result.map_error rresult.r.msg *)
      List.fold_left
        (fun res trust_anchor ->
          match res with
          | Ok () ->
              Logs.info (fun l ->
                  l "Using [trust_anchor %a]" Fpath.pp trust_anchor);
              DkFs_C99.File.copy ~src:trust_anchor
                ~dest:
                  Fpath.(
                    msys2_dir / "etc" / "pki" / "ca-trust" / "source"
                    / "anchors"
                    / Fpath.basename trust_anchor)
                ()
          | Error e -> Error e)
        (Ok ()) trust_anchors
    in
    match trust_anchors with
    | [] -> Ok ()
    | _ ->
        let env = Fpath.(msys2_dir / "usr" / "bin" / "env.exe") in
        let bindir = Fpath.(msys2_dir / "usr" / "bin") in
        let update_ca_trust =
          Fpath.(msys2_dir / "usr" / "bin" / "update-ca-trust")
        in
        OS.Cmd.run
          Cmd.(
            v (Fpath.to_string env)
            % "MSYSTEM=MSYS" % "MSYSTEM_PREFIX=/usr"
            % Fmt.str "PATH=%a" Fpath.pp bindir
            % "dash"
            % (match Logs.level () with
              | Some Logs.Debug | Some Logs.Info -> "-eufx"
              | _ -> "-euf")
            % Fpath.to_string update_ca_trust)

  (** [install_sh ~target] makes a copy of /bin/dash.exe
      to [target], and adds msys-2.0.dll if not present. *)
  let install_sh ~msys2_dir ~target =
    let search = [ Fpath.(msys2_dir / "usr" / "bin") ] in
    let* src_sh_opt = OS.Cmd.find_tool ~search (Cmd.v "dash") in
    match src_sh_opt with
    | None ->
        Error
          (`Msg
            (Fmt.str "Could not find dash.exe in %a"
               Fmt.(Dump.list Fpath.pp)
               search))
    | Some src_sh ->
        let target_dir = Fpath.parent target in
        let* (_created : bool) = OS.Dir.create ~mode:0o750 target_dir in

        let* () = install_msys2_dll_in_targetdir ~msys2_dir ~target_dir in
        DkFs_C99.File.copy ~src:src_sh ~dest:target ()

  let install_utilities t ~trust_anchors =
    let sequence =
      let* () = install_msys2 t in
      let* () =
        install_trust_anchors ~msys2_dir:t.target_msys2_dir ~trust_anchors
      in
      match t.target_sh with
      | None -> Ok ()
      | Some target_sh ->
          install_sh ~msys2_dir:t.target_msys2_dir ~target:(Fpath.v target_sh)
    in
    match sequence with Ok () -> () | Error (`Msg e) -> failwith e
end

(** [install ?bits32 ?target_sh ~target_msys2_dir ~cache_dir] installs MSYS2
    into [target_msys2_dir].

    Intermediate files will be downloaded into [cache_dir].
    
    Use the [~bits32:()] flag to install 32-bit MSYS2. The 32-bit MSYS2 will
    automatically be used if a 32-bit OCaml runtime is running
    (ie. {!Sys.word_size} is 32).
    
    Use [~target_sh = Fpath.v "somewhere/sh.exe"] to install a POSIX shell
    in a separate location. The DLLs will also be installed to that location
    (ex. ["somewhere/msys-2.0.dll"]).
    *)
let install ?bits32 ?(trust_anchors = []) ?msys2_base_exe ?target_sh
    ~target_msys2_dir ~cache_dir () =
  let bits32 =
    match (bits32, Sys.word_size) with None, 32 -> Some () | _ -> bits32
  in
  let installer =
    Installer.create ?bits32 ?msys2_base_exe ?target_sh ~cache_dir
      ~target_msys2_dir ()
  in
  Installer.install_utilities installer ~trust_anchors

module Cli = struct
  let bits32_t =
    let doc =
      "Install 32-bit MSYS2. Use with caution since MSYS2 deprecated 32-bit in \
       May 2020."
    in
    Arg.(value & flag & info ~doc [ "32-bit" ])

  let cache_dit_t =
    let doc =
      "Cache directory to store old MSYS2 installers. You may erase the \
       contents of the cache directory at any time."
    in
    let t = Arg.(required & opt (some dir) None & info ~doc [ "cache-dir" ]) in
    Term.(const Fpath.v $ t)

  let target_msys2_dir_t =
    let doc = "Destination directory for MSYS2" in
    let t =
      Arg.(required & opt (some string) None & info ~doc [ "target-msys2-dir" ])
    in
    Term.(const Fpath.v $ t)

  let target_sh_t =
    let doc =
      "If specified, copy a POSIX shell (MSYS2's $(b,/bin/dash.exe)) to \
       $(docv). Any required DLLs will also be copied to the same directory as \
       $(docv)."
    in
    Arg.(
      value & opt (some string) None & info ~doc ~docv:"SHELL" [ "target-sh" ])

  let curl_exe_opt_t =
    let doc =
      "Location of curl.exe. Required only if --msys2-base-exe is not specified"
    in
    let v = Arg.(value & opt (some file) None & info ~doc [ "curl-exe" ]) in
    Term.(const (Option.map Fpath.v) $ v)

  let msys2_base_exe_opt_t =
    let doc =
      "Location of msys2-base-ARCH-DATE.sfx.exe. If not specified, MSYS2 will \
       be downloaded."
    in
    let v =
      Arg.(value & opt (some file) None & info ~doc [ "msys2-base-exe" ])
    in
    Term.(const (Option.map Fpath.v) $ v)

  let trust_anchors_t =
    let doc =
      "Install $(b,.pem) or $(b,.cer) TLS CA trust anchors to allow downloads \
       from the Internet for MSYS2 packages. Use when your organization has a \
       Internet proxy or firewall with a custom TLS CA certificate. Confer: \
       https://www.msys2.org/docs/faq/#how-can-i-make-msys2pacman-trust-my-companys-custom-tls-ca-certificate"
    in
    let t = Arg.(value & opt_all file [] & info ~doc [ "trust-anchors" ]) in
    Term.(const (List.map Fpath.v) $ t)

  let main_t =
    Term.(
      const
        (fun
          bits32
          cache_dir
          target_msys2_dir
          target_sh
          msys2_base_exe_opt
          trust_anchors
        ->
          install
            ?bits32:(if bits32 then Some () else None)
            ?msys2_base_exe:msys2_base_exe_opt ?target_sh ~trust_anchors
            ~target_msys2_dir ~cache_dir ())
      $ bits32_t $ cache_dit_t $ target_msys2_dir_t $ target_sh_t
      $ msys2_base_exe_opt_t $ trust_anchors_t)

  let cmd = Cmd.v (Cmd.info ("./dk " ^ __MODULE_ID__)) main_t
end

let () =
  if Tr1EntryName.module_id = __MODULE_ID__ then begin
    Tr1Logs_Term.TerminalCliOptions.init ();
    StdExit.exit (Cmdliner.Cmd.eval Cli.cmd)
  end
