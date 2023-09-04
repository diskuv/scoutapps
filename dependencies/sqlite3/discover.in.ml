type variants = {
  option_libprefix : string;
  option_libsuffix : string;
  option_libdir : string;
  cflags : string list;
}

let opt_map ~default ~f = function Some y -> f y | None -> default

let () =
  let module C = Configurator.V1 in
  C.main ~name:"sqlite3" (fun c ->
      let default =
        {
          option_libprefix = "-l";
          option_libsuffix = "";
          option_libdir = "-L";
          cflags = [ "-O2"; "-fPIC"; "-DPIC" ];
        }
      in
      let variant =
        opt_map (C.ocaml_config_var c "ccomp_type") ~default ~f:(function
          | "msvc" ->
              {
                option_libprefix = "";
                option_libsuffix = ".lib";
                option_libdir = "/LIBPATH:";
                cflags = [ "/O2" ];
              }
          | _ -> default)
      in
      let cflags = variant.cflags in
      let libs =
        [
          Printf.sprintf "%s%s" variant.option_libdir {|@sqlite3_LIBDIR@|};
          Printf.sprintf "%ssqlite3%s" variant.option_libprefix
            variant.option_libsuffix;
        ]
      in
      let conf = { C.Pkg_config.cflags; libs } in
      C.Flags.write_sexp "c_flags.sexp" conf.cflags;
      C.Flags.write_sexp "c_library_flags.sexp" conf.libs)
