(** Accumulator of paths as programs and directories are found. *)

type t = { msys2 : Fpath.t option; git : Fpath.t option; paths : Fpath.t list }

let create () = { msys2 = None; git = None; paths = [] }
let add_msys2 t fp = { t with msys2 = Some fp }

let add_git t git_exe =
  let fp_dir = Fpath.parent git_exe in
  { t with git = Some git_exe; paths = fp_dir :: t.paths }

let add_path t path = { t with paths = path :: t.paths }
let paths { paths; _ } = paths
let msys2 { msys2; _ } = msys2
let git { git; _ } = git
