(** Common Sonic Scout CLI code. *)

open Cmdliner

let s_advanced = "ADVANCED OPTIONS"

let help_secs =
  [
    `S Manpage.s_commands;
    `S Manpage.s_common_options;
    `P "These options are common to all commands.";
    `S s_advanced;
    `S Manpage.s_bugs;
    `P
      "Support the project with a GitHub star at \
       https://github.com/diskuv/dkcoder.";
    `P
      "Leave feedback or bug reports at \
       https://github.com/diskuv/dkcoder/issues.";
  ]

let dksdk_data_home_t =
  let doc =
    "Use custom location for the DKSDK_DATA_HOME variable. dksdk-access looks \
     in standard places so it is best not to change the default."
  in
  (* Locate DKSDK_DATA_HOME.
     Source: https://gitlab.com/diskuv/dksdk-access/-/blob/060d2e615a199de37060ed2cffacf4301dc61006/cmake/DkSDKAccess.cmake#L47-60 *)
  let empty_to_none s = if s = Some "" then None else s in
  let default =
    match
      ( empty_to_none @@ Sys.getenv_opt "LOCALAPPDATA",
        empty_to_none @@ Sys.getenv_opt "XDG_DATA_HOME",
        empty_to_none @@ Sys.getenv_opt "HOME" )
    with
    | Some localappdata, _, _ -> Some Fpath.(v localappdata / "DkSDK")
    | _, Some xdgdatahome, _ -> Some Fpath.(v xdgdatahome / "dksdk")
    | _, _, Some home -> Some Fpath.(v home / ".local" / "share" / "dksdk")
    | None, None, None -> None
  in
  let t =
    Arg.(
      value
      & opt (some string) (Option.map Fpath.to_string default)
      & info ~doc [ "dksdk-data-home" ])
  in
  let t =
    Term.(
      const (fun o ->
          Option.map Fpath.v o
          |> Option.to_result
               ~none:
                 "The environment does not have conventional Windows/Unix home \
                  variables so --dksdk-data-home is required.")
      $ t)
  in
  Term.term_result' ~usage:true t

let bool_to_flag t = Term.(const (fun b -> if b then Some () else None) $ t)

let next_t =
  let doc = "Use the 'next' branches of DkSDK which contains beta software." in
  Arg.(value & flag & info ~docs:s_advanced ~doc [ "next" ])

let fetch_siblings_t =
  let doc =
    "Use the sibling directories of `scoutapps` as the locations of the \
     `dkml-runtime-common`, `dkml-runtime-distribution`, `dkml-compiler`, \
     `dksdk-access` and `dksdk-cmake` projects. The sibling directories for \
     `dksdk-ffi-c`, `dksdk-ffi-java` and `dksdk-ffi-ocaml` projects will be \
     git cloned into the `fetch/` subdirectory of SonicScoutBackend and \
     SonicScoutAndroid to support DkSDKFetchContent_DeclareSecondParty()'s \
     location requirements. By default all projects are fetched into the \
     `fetch/` subdirectory from SonicScoutBackend's `dkproject.jsonc` \
     configuration (typically an https git clone)."
  in
  Arg.(value & flag & info ~docs:s_advanced ~doc [ "fetch-siblings" ])

let build_type_t =
  let default =
    match Utils.default_opts.build_type with
    | `Debug -> "Debug"
    | `Release -> "Release"
  in
  let enum =
    [
      (* The first entry is the default. Aka it is a hack for the option's absent rendering *)
      (default, None);
      ("Debug", Some `Debug);
      ("Release", Some `Release);
    ]
  in
  let type_ = Arg.enum enum in
  let enum_alts = Arg.doc_alts_enum List.(tl enum) in
  let doc =
    Printf.sprintf
      "The type of build. The Debug build type has some ability to be \
       debugged, but Debug builds can't be shared with other computers (your \
       team mates!) easily. If a Debug build is shared, the programs may not \
       start. `%s` is the default. $(docv) must be %s."
      default enum_alts
  in
  let t =
    Arg.(value & opt type_ None & info [ "build-type" ] ~docv:"BUILDTYPE" ~doc)
  in
  Term.(const (Option.value ~default:Utils.default_opts.build_type) $ t)

let opts_t =
  Term.(
    const (fun next fetch_siblings build_type : Utils.opts ->
        { next; fetch_siblings; build_type })
    $ next_t $ fetch_siblings_t $ build_type_t)

let global_dkml_t =
  let doc =
    "Install and use the `Diskuv.OCaml` winget package on Windows. This is \
     experimental."
  in
  bool_to_flag Arg.(value & flag & info ~doc [ "global-dkml" ])
