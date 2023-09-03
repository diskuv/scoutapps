[@@@ocaml.warning "-27-32-37-60"]

type ro = Capnp.Message.ro
type rw = Capnp.Message.rw

module type S = sig
  module MessageWrapper : Capnp.RPC.S

  type 'cap message_t = 'cap MessageWrapper.Message.t
  type 'a reader_t = 'a MessageWrapper.StructStorage.reader_t
  type 'a builder_t = 'a MessageWrapper.StructStorage.builder_t

  module Climb_17059552977753218409 : sig
    type t = None | Docked | Engaged | Undefined of int
  end

  module Reader : sig
    type array_t
    type builder_array_t
    type pointer_t = ro MessageWrapper.Slice.t option

    val of_pointer : pointer_t -> 'a reader_t

    module RawMatchData : sig
      type struct_t = [ `RawMatchData_faef7bb13948ce39 ]
      type t = struct_t reader_t

      val team_number_get : t -> int
      val has_team_name : t -> bool
      val team_name_get : t -> string
      val match_number_get : t -> int
      val has_scouter_name : t -> bool
      val scouter_name_get : t -> string
      val incap_get : t -> bool
      val playing_defense_get : t -> bool
      val has_notes : t -> bool
      val notes_get : t -> string
      val auto_mobility_get : t -> bool
      val auto_climb_get : t -> Climb_17059552977753218409.t
      val auto_cone_high_get : t -> int
      val auto_cone_mid_get : t -> int
      val auto_cone_low_get : t -> int
      val auto_cube_high_get : t -> int
      val auto_cube_mid_get : t -> int
      val auto_cube_low_get : t -> int
      val tele_climb_get : t -> Climb_17059552977753218409.t
      val tele_cone_high_get : t -> int
      val tele_cone_mid_get : t -> int
      val tele_cone_low_get : t -> int
      val tele_cube_high_get : t -> int
      val tele_cube_mid_get : t -> int
      val tele_cube_low_get : t -> int
      val of_message : 'cap message_t -> t
      val of_builder : struct_t builder_t -> t
    end

    module Climb : sig
      type t = Climb_17059552977753218409.t =
        | None
        | Docked
        | Engaged
        | Undefined of int
    end
  end

  module Builder : sig
    type array_t = Reader.builder_array_t
    type reader_array_t = Reader.array_t
    type pointer_t = rw MessageWrapper.Slice.t

    module RawMatchData : sig
      type struct_t = [ `RawMatchData_faef7bb13948ce39 ]
      type t = struct_t builder_t

      val team_number_get : t -> int
      val team_number_set_exn : t -> int -> unit
      val has_team_name : t -> bool
      val team_name_get : t -> string
      val team_name_set : t -> string -> unit
      val match_number_get : t -> int
      val match_number_set_exn : t -> int -> unit
      val has_scouter_name : t -> bool
      val scouter_name_get : t -> string
      val scouter_name_set : t -> string -> unit
      val incap_get : t -> bool
      val incap_set : t -> bool -> unit
      val playing_defense_get : t -> bool
      val playing_defense_set : t -> bool -> unit
      val has_notes : t -> bool
      val notes_get : t -> string
      val notes_set : t -> string -> unit
      val auto_mobility_get : t -> bool
      val auto_mobility_set : t -> bool -> unit
      val auto_climb_get : t -> Climb_17059552977753218409.t
      val auto_climb_set : t -> Climb_17059552977753218409.t -> unit
      val auto_climb_set_unsafe : t -> Climb_17059552977753218409.t -> unit
      val auto_cone_high_get : t -> int
      val auto_cone_high_set_exn : t -> int -> unit
      val auto_cone_mid_get : t -> int
      val auto_cone_mid_set_exn : t -> int -> unit
      val auto_cone_low_get : t -> int
      val auto_cone_low_set_exn : t -> int -> unit
      val auto_cube_high_get : t -> int
      val auto_cube_high_set_exn : t -> int -> unit
      val auto_cube_mid_get : t -> int
      val auto_cube_mid_set_exn : t -> int -> unit
      val auto_cube_low_get : t -> int
      val auto_cube_low_set_exn : t -> int -> unit
      val tele_climb_get : t -> Climb_17059552977753218409.t
      val tele_climb_set : t -> Climb_17059552977753218409.t -> unit
      val tele_climb_set_unsafe : t -> Climb_17059552977753218409.t -> unit
      val tele_cone_high_get : t -> int
      val tele_cone_high_set_exn : t -> int -> unit
      val tele_cone_mid_get : t -> int
      val tele_cone_mid_set_exn : t -> int -> unit
      val tele_cone_low_get : t -> int
      val tele_cone_low_set_exn : t -> int -> unit
      val tele_cube_high_get : t -> int
      val tele_cube_high_set_exn : t -> int -> unit
      val tele_cube_mid_get : t -> int
      val tele_cube_mid_set_exn : t -> int -> unit
      val tele_cube_low_get : t -> int
      val tele_cube_low_set_exn : t -> int -> unit
      val of_message : rw message_t -> t
      val to_message : t -> rw message_t
      val to_reader : t -> struct_t reader_t
      val init_root : ?message_size:int -> unit -> t
      val init_pointer : pointer_t -> t
    end

    module Climb : sig
      type t = Climb_17059552977753218409.t =
        | None
        | Docked
        | Engaged
        | Undefined of int
    end
  end
end

module MakeRPC (MessageWrapper : Capnp.RPC.S) = struct
  type 'a reader_t = 'a MessageWrapper.StructStorage.reader_t
  type 'a builder_t = 'a MessageWrapper.StructStorage.builder_t

  module CamlBytes = Bytes
  module DefaultsMessage_ = Capnp.BytesMessage

  let _builder_defaults_message =
    let message_segments = [ Bytes.unsafe_of_string "" ] in
    DefaultsMessage_.Message.readonly
      (DefaultsMessage_.Message.of_storage message_segments)

  let invalid_msg = Capnp.Message.invalid_msg

  include Capnp.Runtime.BuilderInc.Make (MessageWrapper)

  type 'cap message_t = 'cap MessageWrapper.Message.t

  module Climb_17059552977753218409 = struct
    type t = None | Docked | Engaged | Undefined of int

    let decode u16 =
      match u16 with 0 -> None | 1 -> Docked | 2 -> Engaged | v -> Undefined v

    let encode_safe enum =
      match enum with
      | None -> 0
      | Docked -> 1
      | Engaged -> 2
      | Undefined x -> invalid_msg "Cannot encode undefined enum value."

    let encode_unsafe enum =
      match enum with
      | None -> 0
      | Docked -> 1
      | Engaged -> 2
      | Undefined x -> x
  end

  module DefaultsCopier_ =
    Capnp.Runtime.BuilderOps.Make (Capnp.BytesMessage) (MessageWrapper)

  let _reader_defaults_message =
    MessageWrapper.Message.create
      (DefaultsMessage_.Message.total_size _builder_defaults_message)

  module Reader = struct
    type array_t = ro MessageWrapper.ListStorage.t
    type builder_array_t = rw MessageWrapper.ListStorage.t
    type pointer_t = ro MessageWrapper.Slice.t option

    let of_pointer = RA_.deref_opt_struct_pointer

    module RawMatchData = struct
      type struct_t = [ `RawMatchData_faef7bb13948ce39 ]
      type t = struct_t reader_t

      let team_number_get x = RA_.get_int16 ~default:0 x 0
      let has_team_name x = RA_.has_field x 0
      let team_name_get x = RA_.get_text ~default:"" x 0
      let match_number_get x = RA_.get_int16 ~default:0 x 2
      let has_scouter_name x = RA_.has_field x 1
      let scouter_name_get x = RA_.get_text ~default:"" x 1
      let incap_get x = RA_.get_bit ~default:false x ~byte_ofs:4 ~bit_ofs:0

      let playing_defense_get x =
        RA_.get_bit ~default:false x ~byte_ofs:4 ~bit_ofs:1

      let has_notes x = RA_.has_field x 2
      let notes_get x = RA_.get_text ~default:"" x 2

      let auto_mobility_get x =
        RA_.get_bit ~default:false x ~byte_ofs:4 ~bit_ofs:2

      let auto_climb_get x =
        let discr = RA_.get_uint16 ~default:0 x 6 in
        Climb_17059552977753218409.decode discr

      let auto_cone_high_get x = RA_.get_int16 ~default:0 x 8
      let auto_cone_mid_get x = RA_.get_int16 ~default:0 x 10
      let auto_cone_low_get x = RA_.get_int16 ~default:0 x 12
      let auto_cube_high_get x = RA_.get_int16 ~default:0 x 14
      let auto_cube_mid_get x = RA_.get_int16 ~default:0 x 16
      let auto_cube_low_get x = RA_.get_int16 ~default:0 x 18

      let tele_climb_get x =
        let discr = RA_.get_uint16 ~default:0 x 20 in
        Climb_17059552977753218409.decode discr

      let tele_cone_high_get x = RA_.get_int16 ~default:0 x 22
      let tele_cone_mid_get x = RA_.get_int16 ~default:0 x 24
      let tele_cone_low_get x = RA_.get_int16 ~default:0 x 26
      let tele_cube_high_get x = RA_.get_int16 ~default:0 x 28
      let tele_cube_mid_get x = RA_.get_int16 ~default:0 x 30
      let tele_cube_low_get x = RA_.get_int16 ~default:0 x 32
      let of_message x = RA_.get_root_struct (RA_.Message.readonly x)
      let of_builder x = Some (RA_.StructStorage.readonly x)
    end

    module Climb = struct
      type t = Climb_17059552977753218409.t =
        | None
        | Docked
        | Engaged
        | Undefined of int
    end
  end

  module Builder = struct
    type array_t = Reader.builder_array_t
    type reader_array_t = Reader.array_t
    type pointer_t = rw MessageWrapper.Slice.t

    module RawMatchData = struct
      type struct_t = [ `RawMatchData_faef7bb13948ce39 ]
      type t = struct_t builder_t

      let team_number_get x = BA_.get_int16 ~default:0 x 0
      let team_number_set_exn x v = BA_.set_int16 ~default:0 x 0 v
      let has_team_name x = BA_.has_field x 0
      let team_name_get x = BA_.get_text ~default:"" x 0
      let team_name_set x v = BA_.set_text x 0 v
      let match_number_get x = BA_.get_int16 ~default:0 x 2
      let match_number_set_exn x v = BA_.set_int16 ~default:0 x 2 v
      let has_scouter_name x = BA_.has_field x 1
      let scouter_name_get x = BA_.get_text ~default:"" x 1
      let scouter_name_set x v = BA_.set_text x 1 v
      let incap_get x = BA_.get_bit ~default:false x ~byte_ofs:4 ~bit_ofs:0
      let incap_set x v = BA_.set_bit ~default:false x ~byte_ofs:4 ~bit_ofs:0 v

      let playing_defense_get x =
        BA_.get_bit ~default:false x ~byte_ofs:4 ~bit_ofs:1

      let playing_defense_set x v =
        BA_.set_bit ~default:false x ~byte_ofs:4 ~bit_ofs:1 v

      let has_notes x = BA_.has_field x 2
      let notes_get x = BA_.get_text ~default:"" x 2
      let notes_set x v = BA_.set_text x 2 v

      let auto_mobility_get x =
        BA_.get_bit ~default:false x ~byte_ofs:4 ~bit_ofs:2

      let auto_mobility_set x v =
        BA_.set_bit ~default:false x ~byte_ofs:4 ~bit_ofs:2 v

      let auto_climb_get x =
        let discr = BA_.get_uint16 ~default:0 x 6 in
        Climb_17059552977753218409.decode discr

      let auto_climb_set x e =
        BA_.set_uint16 ~default:0 x 6 (Climb_17059552977753218409.encode_safe e)

      let auto_climb_set_unsafe x e =
        BA_.set_uint16 ~default:0 x 6
          (Climb_17059552977753218409.encode_unsafe e)

      let auto_cone_high_get x = BA_.get_int16 ~default:0 x 8
      let auto_cone_high_set_exn x v = BA_.set_int16 ~default:0 x 8 v
      let auto_cone_mid_get x = BA_.get_int16 ~default:0 x 10
      let auto_cone_mid_set_exn x v = BA_.set_int16 ~default:0 x 10 v
      let auto_cone_low_get x = BA_.get_int16 ~default:0 x 12
      let auto_cone_low_set_exn x v = BA_.set_int16 ~default:0 x 12 v
      let auto_cube_high_get x = BA_.get_int16 ~default:0 x 14
      let auto_cube_high_set_exn x v = BA_.set_int16 ~default:0 x 14 v
      let auto_cube_mid_get x = BA_.get_int16 ~default:0 x 16
      let auto_cube_mid_set_exn x v = BA_.set_int16 ~default:0 x 16 v
      let auto_cube_low_get x = BA_.get_int16 ~default:0 x 18
      let auto_cube_low_set_exn x v = BA_.set_int16 ~default:0 x 18 v

      let tele_climb_get x =
        let discr = BA_.get_uint16 ~default:0 x 20 in
        Climb_17059552977753218409.decode discr

      let tele_climb_set x e =
        BA_.set_uint16 ~default:0 x 20
          (Climb_17059552977753218409.encode_safe e)

      let tele_climb_set_unsafe x e =
        BA_.set_uint16 ~default:0 x 20
          (Climb_17059552977753218409.encode_unsafe e)

      let tele_cone_high_get x = BA_.get_int16 ~default:0 x 22
      let tele_cone_high_set_exn x v = BA_.set_int16 ~default:0 x 22 v
      let tele_cone_mid_get x = BA_.get_int16 ~default:0 x 24
      let tele_cone_mid_set_exn x v = BA_.set_int16 ~default:0 x 24 v
      let tele_cone_low_get x = BA_.get_int16 ~default:0 x 26
      let tele_cone_low_set_exn x v = BA_.set_int16 ~default:0 x 26 v
      let tele_cube_high_get x = BA_.get_int16 ~default:0 x 28
      let tele_cube_high_set_exn x v = BA_.set_int16 ~default:0 x 28 v
      let tele_cube_mid_get x = BA_.get_int16 ~default:0 x 30
      let tele_cube_mid_set_exn x v = BA_.set_int16 ~default:0 x 30 v
      let tele_cube_low_get x = BA_.get_int16 ~default:0 x 32
      let tele_cube_low_set_exn x v = BA_.set_int16 ~default:0 x 32 v
      let of_message x = BA_.get_root_struct ~data_words:5 ~pointer_words:3 x
      let to_message x = x.BA_.NM.StructStorage.data.MessageWrapper.Slice.msg
      let to_reader x = Some (RA_.StructStorage.readonly x)

      let init_root ?message_size () =
        BA_.alloc_root_struct ?message_size ~data_words:5 ~pointer_words:3 ()

      let init_pointer ptr =
        BA_.init_struct_pointer ptr ~data_words:5 ~pointer_words:3
    end

    module Climb = struct
      type t = Climb_17059552977753218409.t =
        | None
        | Docked
        | Engaged
        | Undefined of int
    end
  end

  module Client = struct end
  module Service = struct end
  module MessageWrapper = MessageWrapper
end

module Make (M : Capnp.MessageSig.S) = MakeRPC (Capnp.RPC.None (M))
