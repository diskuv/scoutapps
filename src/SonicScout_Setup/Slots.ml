(** Accumulator of paths as programs and directories are found. *)

type t = {
  msys2 : Fpath.t option;
  git : Fpath.t option;
  vsdir : Fpath.t option;
  uv : Fpath.t option;
  uv_cache : Fpath.t option;
  uv_install : Fpath.t option;
  python_version : string option;
  paths : Fpath.t list;
}

let create () =
  {
    msys2 = None;
    git = None;
    vsdir = None;
    uv = None;
    uv_cache = None;
    uv_install = None;
    python_version = None;
    paths = [];
  }

let add_msys2 t fp = { t with msys2 = Some fp }

let add_git t git_exe =
  let fp_dir = Fpath.parent git_exe in
  { t with git = Some git_exe; paths = fp_dir :: t.paths }

let add_vsdir t vsdir = { t with vsdir = Some vsdir }

let add_uv ~cache_dir t uv_exe =
  let fp_dir = Fpath.parent uv_exe in
  {
    t with
    uv = Some uv_exe;
    uv_cache = Some cache_dir;
    paths = fp_dir :: t.paths;
  }

let add_uv_install ~version t uv_install_dir =
  { t with uv_install = Some uv_install_dir; python_version = Some version }

let add_path t path = { t with paths = path :: t.paths }
let paths { paths; _ } = paths
let msys2 { msys2; _ } = msys2
let git { git; _ } = git
let uv { uv; _ } = uv

let vsdir_exn { vsdir; _ } =
  match vsdir with
  | None ->
      failwith
        "The [vsdir] slot has not been filled. Make sure the setup script \
         calls [VisualStudio.run]"
  | Some v -> v

let uv_cache { uv_cache; _ } = uv_cache
let uv_install { uv_install; _ } = uv_install
let python_version { python_version; _ } = python_version
