(* The basename of this module is a DkCoder library id, so DkCoder will skip
   this module. Therefore it is only used in DkSDK CMake (native code). *)

(* The SonicScout_Std package did not link with DkSDK::OCamlCompile. Only
   SonicScout_ObjsLib did that.
   
   Since DkCoder uses DkSDKFFI_OCaml in this package when operating on the
   capnp schema (to get around a bug and also for consistency), we avoid
   changing the DkSDK CMake behavior by making this mock DkSDKFFI_OCaml module. *)
module DkSDKFFI_OCaml = struct
  (* WAS: Raw_match_data_table.ml| let module ProjectSchema = Schema.Make (Capnp.BytesMessage)
     NOW: Raw_match_data_table.ml| let module ProjectSchema = Schema.Make (DkSDKFFI_OCaml.ComMessageC) *)
  module ComMessageC = Capnp.BytesMessage

  (* WAS: Raw_match_data_table.ml| <nothing>
     NOW: Raw_match_data_table.ml| DkSDKFFI_OCaml.HostStorageOptions.C_Options.host_segment_allocator *)
  module HostStorageOptions = struct
    module C_Options = struct
      let host_segment_allocator = `Mock_host_segment_allocator
    end
  end

  (* WAS: Raw_match_data_table.ml| Capnp.Codecs.FramedStream.of_string ~compression:`None capnp_string
     NOW: Raw_match_data_table.ml| DkSDKFFI_OCaml.ComCodecs.FramedStreamC.of_string
          ~host_segment_allocator
          ~compression:`None capnp_string *)
  (* WAS: Raw_match_data_table.ml| Capnp.Codecs.FramedStream.get_next_frame
     NOW: Raw_match_data_table.ml| DkSDKFFI_OCaml.ComCodecs.FramedStreamC.get_next_frame *)
  module ComCodecs = struct
    module FramedStreamC = struct
      let of_string ~host_segment_allocator:_ = Capnp.Codecs.FramedStream.of_string
      let get_next_frame = Capnp.Codecs.FramedStream.get_next_frame
    end
  end
end