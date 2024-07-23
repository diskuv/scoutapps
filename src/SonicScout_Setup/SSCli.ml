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
    "Use the sibling directories of `scoutapps` to locate `dksdk-cmake` and \
     other fetch/ directories."
  in
  Arg.(value & flag & info ~docs:s_advanced ~doc [ "fetch-siblings" ])

let opts_t =
  Term.(
    const (fun next fetch_siblings : Utils.opts -> { next; fetch_siblings })
    $ next_t $ fetch_siblings_t)

let global_dkml_t =
  let doc =
    "Install and use the `Diskuv.OCaml` winget package on Windows. This is \
     experimental."
  in
  bool_to_flag Arg.(value & flag & info ~doc [ "global-dkml" ])
