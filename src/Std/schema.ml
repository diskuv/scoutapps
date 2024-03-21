[@@@ocaml.warning "-27-32-37-60"]

type ro = Capnp.Message.ro
type rw = Capnp.Message.rw

module type S = sig
  module MessageWrapper : Capnp.RPC.S
  type 'cap message_t = 'cap MessageWrapper.Message.t
  type 'a reader_t = 'a MessageWrapper.StructStorage.reader_t
  type 'a builder_t = 'a MessageWrapper.StructStorage.builder_t

  module RobotPosition_16615598200473616182 : sig
    type t =
      | Red1
      | Red2
      | Red3
      | Blue1
      | Blue2
      | Blue3
      | Undefined of int
  end
  module EClimb_13533464256854897024 : sig
    type t =
      | Success
      | Failed
      | DidNotAttempt
      | Harmony
      | Parked
      | Undefined of int
  end
  module TBreakdown_16560530708388719165 : sig
    type t =
      | None
      | Tipped
      | MechanicalFailure
      | Incapacitated
      | Undefined of int
  end
  module SPosition_15975123903786802361 : sig
    type t =
      | AmpSide
      | Center
      | SourceSide
      | Undefined of int
  end

  module Reader : sig
    type array_t
    type builder_array_t
    type pointer_t = ro MessageWrapper.Slice.t option
    val of_pointer : pointer_t -> 'a reader_t
    module RawMatchData : sig
      type struct_t = [`RawMatchData_faef7bb13948ce39]
      type t = struct_t reader_t
      val team_number_get : t -> int
      val has_team_name : t -> bool
      val team_name_get : t -> string
      val match_number_get : t -> int
      val has_scouter_name : t -> bool
      val scouter_name_get : t -> string
      val alliance_color_get : t -> RobotPosition_16615598200473616182.t
      val starting_position_get : t -> SPosition_15975123903786802361.t
      val wing_note1_get : t -> bool
      val wing_note2_get : t -> bool
      val wing_note3_get : t -> bool
      val center_note1_get : t -> bool
      val center_note2_get : t -> bool
      val center_note3_get : t -> bool
      val center_note4_get : t -> bool
      val center_note5_get : t -> bool
      val auto_amp_score_get : t -> int
      val auto_amp_miss_get : t -> int
      val auto_speaker_score_get : t -> int
      val auto_speaker_miss_get : t -> int
      val auto_leave_get : t -> bool
      val tele_speaker_score_get : t -> int
      val tele_speaker_miss_get : t -> int
      val tele_amp_score_get : t -> int
      val tele_amp_miss_get : t -> int
      val has_distance : t -> bool
      val distance_get : t -> string
      val tele_breakdown_get : t -> TBreakdown_16560530708388719165.t
      val has_tele_pickup : t -> bool
      val tele_pickup_get : t -> string
      val endgame_climb_get : t -> EClimb_13533464256854897024.t
      val endgame_trap_get : t -> bool
      val of_message : 'cap message_t -> t
      val of_builder : struct_t builder_t -> t
    end
    module SPosition : sig
      type t = SPosition_15975123903786802361.t =
        | AmpSide
        | Center
        | SourceSide
        | Undefined of int
    end
    module TBreakdown : sig
      type t = TBreakdown_16560530708388719165.t =
        | None
        | Tipped
        | MechanicalFailure
        | Incapacitated
        | Undefined of int
    end
    module EClimb : sig
      type t = EClimb_13533464256854897024.t =
        | Success
        | Failed
        | DidNotAttempt
        | Harmony
        | Parked
        | Undefined of int
    end
    module RobotPosition : sig
      type t = RobotPosition_16615598200473616182.t =
        | Red1
        | Red2
        | Red3
        | Blue1
        | Blue2
        | Blue3
        | Undefined of int
    end
    module MatchAndPosition : sig
      type struct_t = [`MatchAndPosition_fcb71e38a70d3910]
      type t = struct_t reader_t
      val match_get : t -> int
      val position_get : t -> RobotPosition.t
      val of_message : 'cap message_t -> t
      val of_builder : struct_t builder_t -> t
    end
    module MaybeError : sig
      type struct_t = [`MaybeError_db6aa7ecdb8f85bb]
      type t = struct_t reader_t
      val success_get : t -> bool
      val has_message_if_error : t -> bool
      val message_if_error_get : t -> string
      val of_message : 'cap message_t -> t
      val of_builder : struct_t builder_t -> t
    end
  end

  module Builder : sig
    type array_t = Reader.builder_array_t
    type reader_array_t = Reader.array_t
    type pointer_t = rw MessageWrapper.Slice.t
    module RawMatchData : sig
      type struct_t = [`RawMatchData_faef7bb13948ce39]
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
      val alliance_color_get : t -> RobotPosition_16615598200473616182.t
      val alliance_color_set : t -> RobotPosition_16615598200473616182.t -> unit
      val alliance_color_set_unsafe : t -> RobotPosition_16615598200473616182.t -> unit
      val starting_position_get : t -> SPosition_15975123903786802361.t
      val starting_position_set : t -> SPosition_15975123903786802361.t -> unit
      val starting_position_set_unsafe : t -> SPosition_15975123903786802361.t -> unit
      val wing_note1_get : t -> bool
      val wing_note1_set : t -> bool -> unit
      val wing_note2_get : t -> bool
      val wing_note2_set : t -> bool -> unit
      val wing_note3_get : t -> bool
      val wing_note3_set : t -> bool -> unit
      val center_note1_get : t -> bool
      val center_note1_set : t -> bool -> unit
      val center_note2_get : t -> bool
      val center_note2_set : t -> bool -> unit
      val center_note3_get : t -> bool
      val center_note3_set : t -> bool -> unit
      val center_note4_get : t -> bool
      val center_note4_set : t -> bool -> unit
      val center_note5_get : t -> bool
      val center_note5_set : t -> bool -> unit
      val auto_amp_score_get : t -> int
      val auto_amp_score_set_exn : t -> int -> unit
      val auto_amp_miss_get : t -> int
      val auto_amp_miss_set_exn : t -> int -> unit
      val auto_speaker_score_get : t -> int
      val auto_speaker_score_set_exn : t -> int -> unit
      val auto_speaker_miss_get : t -> int
      val auto_speaker_miss_set_exn : t -> int -> unit
      val auto_leave_get : t -> bool
      val auto_leave_set : t -> bool -> unit
      val tele_speaker_score_get : t -> int
      val tele_speaker_score_set_exn : t -> int -> unit
      val tele_speaker_miss_get : t -> int
      val tele_speaker_miss_set_exn : t -> int -> unit
      val tele_amp_score_get : t -> int
      val tele_amp_score_set_exn : t -> int -> unit
      val tele_amp_miss_get : t -> int
      val tele_amp_miss_set_exn : t -> int -> unit
      val has_distance : t -> bool
      val distance_get : t -> string
      val distance_set : t -> string -> unit
      val tele_breakdown_get : t -> TBreakdown_16560530708388719165.t
      val tele_breakdown_set : t -> TBreakdown_16560530708388719165.t -> unit
      val tele_breakdown_set_unsafe : t -> TBreakdown_16560530708388719165.t -> unit
      val has_tele_pickup : t -> bool
      val tele_pickup_get : t -> string
      val tele_pickup_set : t -> string -> unit
      val endgame_climb_get : t -> EClimb_13533464256854897024.t
      val endgame_climb_set : t -> EClimb_13533464256854897024.t -> unit
      val endgame_climb_set_unsafe : t -> EClimb_13533464256854897024.t -> unit
      val endgame_trap_get : t -> bool
      val endgame_trap_set : t -> bool -> unit
      val of_message : rw message_t -> t
      val to_message : t -> rw message_t
      val to_reader : t -> struct_t reader_t
      val init_root : ?message_size:int -> unit -> t
      val init_pointer : pointer_t -> t
    end
    module SPosition : sig
      type t = SPosition_15975123903786802361.t =
        | AmpSide
        | Center
        | SourceSide
        | Undefined of int
    end
    module TBreakdown : sig
      type t = TBreakdown_16560530708388719165.t =
        | None
        | Tipped
        | MechanicalFailure
        | Incapacitated
        | Undefined of int
    end
    module EClimb : sig
      type t = EClimb_13533464256854897024.t =
        | Success
        | Failed
        | DidNotAttempt
        | Harmony
        | Parked
        | Undefined of int
    end
    module RobotPosition : sig
      type t = RobotPosition_16615598200473616182.t =
        | Red1
        | Red2
        | Red3
        | Blue1
        | Blue2
        | Blue3
        | Undefined of int
    end
    module MatchAndPosition : sig
      type struct_t = [`MatchAndPosition_fcb71e38a70d3910]
      type t = struct_t builder_t
      val match_get : t -> int
      val match_set_exn : t -> int -> unit
      val position_get : t -> RobotPosition.t
      val position_set : t -> RobotPosition.t -> unit
      val position_set_unsafe : t -> RobotPosition.t -> unit
      val of_message : rw message_t -> t
      val to_message : t -> rw message_t
      val to_reader : t -> struct_t reader_t
      val init_root : ?message_size:int -> unit -> t
      val init_pointer : pointer_t -> t
    end
    module MaybeError : sig
      type struct_t = [`MaybeError_db6aa7ecdb8f85bb]
      type t = struct_t builder_t
      val success_get : t -> bool
      val success_set : t -> bool -> unit
      val has_message_if_error : t -> bool
      val message_if_error_get : t -> string
      val message_if_error_set : t -> string -> unit
      val of_message : rw message_t -> t
      val to_message : t -> rw message_t
      val to_reader : t -> struct_t reader_t
      val init_root : ?message_size:int -> unit -> t
      val init_pointer : pointer_t -> t
    end
  end
end

module MakeRPC(MessageWrapper : Capnp.RPC.S) = struct
  type 'a reader_t = 'a MessageWrapper.StructStorage.reader_t
  type 'a builder_t = 'a MessageWrapper.StructStorage.builder_t
  module CamlBytes = Bytes
  module DefaultsMessage_ = Capnp.BytesMessage

  let _builder_defaults_message =
    let message_segments = [
      Bytes.unsafe_of_string "\
      ";
    ] in
    DefaultsMessage_.Message.readonly
      (DefaultsMessage_.Message.of_storage message_segments)

  let invalid_msg = Capnp.Message.invalid_msg

  include Capnp.Runtime.BuilderInc.Make(MessageWrapper)

  type 'cap message_t = 'cap MessageWrapper.Message.t

  module RobotPosition_16615598200473616182 = struct
    type t =
      | Red1
      | Red2
      | Red3
      | Blue1
      | Blue2
      | Blue3
      | Undefined of int
    let decode u16 = match u16 with
      | 0 -> Red1
      | 1 -> Red2
      | 2 -> Red3
      | 3 -> Blue1
      | 4 -> Blue2
      | 5 -> Blue3
      | v -> Undefined v
    let encode_safe enum = match enum with
      | Red1 -> 0
      | Red2 -> 1
      | Red3 -> 2
      | Blue1 -> 3
      | Blue2 -> 4
      | Blue3 -> 5
      | Undefined x -> invalid_msg "Cannot encode undefined enum value."
    let encode_unsafe enum = match enum with
      | Red1 -> 0
      | Red2 -> 1
      | Red3 -> 2
      | Blue1 -> 3
      | Blue2 -> 4
      | Blue3 -> 5
      | Undefined x -> x
  end
  module EClimb_13533464256854897024 = struct
    type t =
      | Success
      | Failed
      | DidNotAttempt
      | Harmony
      | Parked
      | Undefined of int
    let decode u16 = match u16 with
      | 0 -> Success
      | 1 -> Failed
      | 2 -> DidNotAttempt
      | 3 -> Harmony
      | 4 -> Parked
      | v -> Undefined v
    let encode_safe enum = match enum with
      | Success -> 0
      | Failed -> 1
      | DidNotAttempt -> 2
      | Harmony -> 3
      | Parked -> 4
      | Undefined x -> invalid_msg "Cannot encode undefined enum value."
    let encode_unsafe enum = match enum with
      | Success -> 0
      | Failed -> 1
      | DidNotAttempt -> 2
      | Harmony -> 3
      | Parked -> 4
      | Undefined x -> x
  end
  module TBreakdown_16560530708388719165 = struct
    type t =
      | None
      | Tipped
      | MechanicalFailure
      | Incapacitated
      | Undefined of int
    let decode u16 = match u16 with
      | 0 -> None
      | 1 -> Tipped
      | 2 -> MechanicalFailure
      | 3 -> Incapacitated
      | v -> Undefined v
    let encode_safe enum = match enum with
      | None -> 0
      | Tipped -> 1
      | MechanicalFailure -> 2
      | Incapacitated -> 3
      | Undefined x -> invalid_msg "Cannot encode undefined enum value."
    let encode_unsafe enum = match enum with
      | None -> 0
      | Tipped -> 1
      | MechanicalFailure -> 2
      | Incapacitated -> 3
      | Undefined x -> x
  end
  module SPosition_15975123903786802361 = struct
    type t =
      | AmpSide
      | Center
      | SourceSide
      | Undefined of int
    let decode u16 = match u16 with
      | 0 -> AmpSide
      | 1 -> Center
      | 2 -> SourceSide
      | v -> Undefined v
    let encode_safe enum = match enum with
      | AmpSide -> 0
      | Center -> 1
      | SourceSide -> 2
      | Undefined x -> invalid_msg "Cannot encode undefined enum value."
    let encode_unsafe enum = match enum with
      | AmpSide -> 0
      | Center -> 1
      | SourceSide -> 2
      | Undefined x -> x
  end
  module DefaultsCopier_ =
    Capnp.Runtime.BuilderOps.Make(Capnp.BytesMessage)(MessageWrapper)

  let _reader_defaults_message =
    MessageWrapper.Message.create
      (DefaultsMessage_.Message.total_size _builder_defaults_message)


  module Reader = struct
    type array_t = ro MessageWrapper.ListStorage.t
    type builder_array_t = rw MessageWrapper.ListStorage.t
    type pointer_t = ro MessageWrapper.Slice.t option
    let of_pointer = RA_.deref_opt_struct_pointer

    module RawMatchData = struct
      type struct_t = [`RawMatchData_faef7bb13948ce39]
      type t = struct_t reader_t
      let team_number_get x =
        RA_.get_int16 ~default:(0) x 0
      let has_team_name x =
        RA_.has_field x 0
      let team_name_get x =
        RA_.get_text ~default:"" x 0
      let match_number_get x =
        RA_.get_int16 ~default:(0) x 2
      let has_scouter_name x =
        RA_.has_field x 1
      let scouter_name_get x =
        RA_.get_text ~default:"" x 1
      let alliance_color_get x =
        let discr = RA_.get_uint16 ~default:0 x 4 in
        RobotPosition_16615598200473616182.decode discr
      let starting_position_get x =
        let discr = RA_.get_uint16 ~default:0 x 6 in
        SPosition_15975123903786802361.decode discr
      let wing_note1_get x =
        RA_.get_bit ~default:false x ~byte_ofs:8 ~bit_ofs:0
      let wing_note2_get x =
        RA_.get_bit ~default:false x ~byte_ofs:8 ~bit_ofs:1
      let wing_note3_get x =
        RA_.get_bit ~default:false x ~byte_ofs:8 ~bit_ofs:2
      let center_note1_get x =
        RA_.get_bit ~default:false x ~byte_ofs:8 ~bit_ofs:3
      let center_note2_get x =
        RA_.get_bit ~default:false x ~byte_ofs:8 ~bit_ofs:4
      let center_note3_get x =
        RA_.get_bit ~default:false x ~byte_ofs:8 ~bit_ofs:5
      let center_note4_get x =
        RA_.get_bit ~default:false x ~byte_ofs:8 ~bit_ofs:6
      let center_note5_get x =
        RA_.get_bit ~default:false x ~byte_ofs:8 ~bit_ofs:7
      let auto_amp_score_get x =
        RA_.get_int16 ~default:(0) x 10
      let auto_amp_miss_get x =
        RA_.get_int16 ~default:(0) x 12
      let auto_speaker_score_get x =
        RA_.get_int16 ~default:(0) x 14
      let auto_speaker_miss_get x =
        RA_.get_int16 ~default:(0) x 16
      let auto_leave_get x =
        RA_.get_bit ~default:false x ~byte_ofs:9 ~bit_ofs:0
      let tele_speaker_score_get x =
        RA_.get_int16 ~default:(0) x 18
      let tele_speaker_miss_get x =
        RA_.get_int16 ~default:(0) x 20
      let tele_amp_score_get x =
        RA_.get_int16 ~default:(0) x 22
      let tele_amp_miss_get x =
        RA_.get_int16 ~default:(0) x 24
      let has_distance x =
        RA_.has_field x 2
      let distance_get x =
        RA_.get_text ~default:"" x 2
      let tele_breakdown_get x =
        let discr = RA_.get_uint16 ~default:0 x 26 in
        TBreakdown_16560530708388719165.decode discr
      let has_tele_pickup x =
        RA_.has_field x 3
      let tele_pickup_get x =
        RA_.get_text ~default:"" x 3
      let endgame_climb_get x =
        let discr = RA_.get_uint16 ~default:0 x 28 in
        EClimb_13533464256854897024.decode discr
      let endgame_trap_get x =
        RA_.get_bit ~default:false x ~byte_ofs:9 ~bit_ofs:1
      let of_message x = RA_.get_root_struct (RA_.Message.readonly x)
      let of_builder x = Some (RA_.StructStorage.readonly x)
    end
    module SPosition = struct
      type t = SPosition_15975123903786802361.t =
        | AmpSide
        | Center
        | SourceSide
        | Undefined of int
    end
    module TBreakdown = struct
      type t = TBreakdown_16560530708388719165.t =
        | None
        | Tipped
        | MechanicalFailure
        | Incapacitated
        | Undefined of int
    end
    module EClimb = struct
      type t = EClimb_13533464256854897024.t =
        | Success
        | Failed
        | DidNotAttempt
        | Harmony
        | Parked
        | Undefined of int
    end
    module RobotPosition = struct
      type t = RobotPosition_16615598200473616182.t =
        | Red1
        | Red2
        | Red3
        | Blue1
        | Blue2
        | Blue3
        | Undefined of int
    end
    module MatchAndPosition = struct
      type struct_t = [`MatchAndPosition_fcb71e38a70d3910]
      type t = struct_t reader_t
      let match_get x =
        RA_.get_int16 ~default:(0) x 0
      let position_get x =
        let discr = RA_.get_uint16 ~default:0 x 2 in
        RobotPosition_16615598200473616182.decode discr
      let of_message x = RA_.get_root_struct (RA_.Message.readonly x)
      let of_builder x = Some (RA_.StructStorage.readonly x)
    end
    module MaybeError = struct
      type struct_t = [`MaybeError_db6aa7ecdb8f85bb]
      type t = struct_t reader_t
      let success_get x =
        RA_.get_bit ~default:false x ~byte_ofs:0 ~bit_ofs:0
      let has_message_if_error x =
        RA_.has_field x 0
      let message_if_error_get x =
        RA_.get_text ~default:"" x 0
      let of_message x = RA_.get_root_struct (RA_.Message.readonly x)
      let of_builder x = Some (RA_.StructStorage.readonly x)
    end
  end

  module Builder = struct
    type array_t = Reader.builder_array_t
    type reader_array_t = Reader.array_t
    type pointer_t = rw MessageWrapper.Slice.t

    module RawMatchData = struct
      type struct_t = [`RawMatchData_faef7bb13948ce39]
      type t = struct_t builder_t
      let team_number_get x =
        BA_.get_int16 ~default:(0) x 0
      let team_number_set_exn x v =
        BA_.set_int16 ~default:(0) x 0 v
      let has_team_name x =
        BA_.has_field x 0
      let team_name_get x =
        BA_.get_text ~default:"" x 0
      let team_name_set x v =
        BA_.set_text x 0 v
      let match_number_get x =
        BA_.get_int16 ~default:(0) x 2
      let match_number_set_exn x v =
        BA_.set_int16 ~default:(0) x 2 v
      let has_scouter_name x =
        BA_.has_field x 1
      let scouter_name_get x =
        BA_.get_text ~default:"" x 1
      let scouter_name_set x v =
        BA_.set_text x 1 v
      let alliance_color_get x =
        let discr = BA_.get_uint16 ~default:0 x 4 in
        RobotPosition_16615598200473616182.decode discr
      let alliance_color_set x e =
        BA_.set_uint16 ~default:0 x 4 (RobotPosition_16615598200473616182.encode_safe e)
      let alliance_color_set_unsafe x e =
        BA_.set_uint16 ~default:0 x 4 (RobotPosition_16615598200473616182.encode_unsafe e)
      let starting_position_get x =
        let discr = BA_.get_uint16 ~default:0 x 6 in
        SPosition_15975123903786802361.decode discr
      let starting_position_set x e =
        BA_.set_uint16 ~default:0 x 6 (SPosition_15975123903786802361.encode_safe e)
      let starting_position_set_unsafe x e =
        BA_.set_uint16 ~default:0 x 6 (SPosition_15975123903786802361.encode_unsafe e)
      let wing_note1_get x =
        BA_.get_bit ~default:false x ~byte_ofs:8 ~bit_ofs:0
      let wing_note1_set x v =
        BA_.set_bit ~default:false x ~byte_ofs:8 ~bit_ofs:0 v
      let wing_note2_get x =
        BA_.get_bit ~default:false x ~byte_ofs:8 ~bit_ofs:1
      let wing_note2_set x v =
        BA_.set_bit ~default:false x ~byte_ofs:8 ~bit_ofs:1 v
      let wing_note3_get x =
        BA_.get_bit ~default:false x ~byte_ofs:8 ~bit_ofs:2
      let wing_note3_set x v =
        BA_.set_bit ~default:false x ~byte_ofs:8 ~bit_ofs:2 v
      let center_note1_get x =
        BA_.get_bit ~default:false x ~byte_ofs:8 ~bit_ofs:3
      let center_note1_set x v =
        BA_.set_bit ~default:false x ~byte_ofs:8 ~bit_ofs:3 v
      let center_note2_get x =
        BA_.get_bit ~default:false x ~byte_ofs:8 ~bit_ofs:4
      let center_note2_set x v =
        BA_.set_bit ~default:false x ~byte_ofs:8 ~bit_ofs:4 v
      let center_note3_get x =
        BA_.get_bit ~default:false x ~byte_ofs:8 ~bit_ofs:5
      let center_note3_set x v =
        BA_.set_bit ~default:false x ~byte_ofs:8 ~bit_ofs:5 v
      let center_note4_get x =
        BA_.get_bit ~default:false x ~byte_ofs:8 ~bit_ofs:6
      let center_note4_set x v =
        BA_.set_bit ~default:false x ~byte_ofs:8 ~bit_ofs:6 v
      let center_note5_get x =
        BA_.get_bit ~default:false x ~byte_ofs:8 ~bit_ofs:7
      let center_note5_set x v =
        BA_.set_bit ~default:false x ~byte_ofs:8 ~bit_ofs:7 v
      let auto_amp_score_get x =
        BA_.get_int16 ~default:(0) x 10
      let auto_amp_score_set_exn x v =
        BA_.set_int16 ~default:(0) x 10 v
      let auto_amp_miss_get x =
        BA_.get_int16 ~default:(0) x 12
      let auto_amp_miss_set_exn x v =
        BA_.set_int16 ~default:(0) x 12 v
      let auto_speaker_score_get x =
        BA_.get_int16 ~default:(0) x 14
      let auto_speaker_score_set_exn x v =
        BA_.set_int16 ~default:(0) x 14 v
      let auto_speaker_miss_get x =
        BA_.get_int16 ~default:(0) x 16
      let auto_speaker_miss_set_exn x v =
        BA_.set_int16 ~default:(0) x 16 v
      let auto_leave_get x =
        BA_.get_bit ~default:false x ~byte_ofs:9 ~bit_ofs:0
      let auto_leave_set x v =
        BA_.set_bit ~default:false x ~byte_ofs:9 ~bit_ofs:0 v
      let tele_speaker_score_get x =
        BA_.get_int16 ~default:(0) x 18
      let tele_speaker_score_set_exn x v =
        BA_.set_int16 ~default:(0) x 18 v
      let tele_speaker_miss_get x =
        BA_.get_int16 ~default:(0) x 20
      let tele_speaker_miss_set_exn x v =
        BA_.set_int16 ~default:(0) x 20 v
      let tele_amp_score_get x =
        BA_.get_int16 ~default:(0) x 22
      let tele_amp_score_set_exn x v =
        BA_.set_int16 ~default:(0) x 22 v
      let tele_amp_miss_get x =
        BA_.get_int16 ~default:(0) x 24
      let tele_amp_miss_set_exn x v =
        BA_.set_int16 ~default:(0) x 24 v
      let has_distance x =
        BA_.has_field x 2
      let distance_get x =
        BA_.get_text ~default:"" x 2
      let distance_set x v =
        BA_.set_text x 2 v
      let tele_breakdown_get x =
        let discr = BA_.get_uint16 ~default:0 x 26 in
        TBreakdown_16560530708388719165.decode discr
      let tele_breakdown_set x e =
        BA_.set_uint16 ~default:0 x 26 (TBreakdown_16560530708388719165.encode_safe e)
      let tele_breakdown_set_unsafe x e =
        BA_.set_uint16 ~default:0 x 26 (TBreakdown_16560530708388719165.encode_unsafe e)
      let has_tele_pickup x =
        BA_.has_field x 3
      let tele_pickup_get x =
        BA_.get_text ~default:"" x 3
      let tele_pickup_set x v =
        BA_.set_text x 3 v
      let endgame_climb_get x =
        let discr = BA_.get_uint16 ~default:0 x 28 in
        EClimb_13533464256854897024.decode discr
      let endgame_climb_set x e =
        BA_.set_uint16 ~default:0 x 28 (EClimb_13533464256854897024.encode_safe e)
      let endgame_climb_set_unsafe x e =
        BA_.set_uint16 ~default:0 x 28 (EClimb_13533464256854897024.encode_unsafe e)
      let endgame_trap_get x =
        BA_.get_bit ~default:false x ~byte_ofs:9 ~bit_ofs:1
      let endgame_trap_set x v =
        BA_.set_bit ~default:false x ~byte_ofs:9 ~bit_ofs:1 v
      let of_message x = BA_.get_root_struct ~data_words:4 ~pointer_words:4 x
      let to_message x = x.BA_.NM.StructStorage.data.MessageWrapper.Slice.msg
      let to_reader x = Some (RA_.StructStorage.readonly x)
      let init_root ?message_size () =
        BA_.alloc_root_struct ?message_size ~data_words:4 ~pointer_words:4 ()
      let init_pointer ptr =
        BA_.init_struct_pointer ptr ~data_words:4 ~pointer_words:4
    end
    module SPosition = struct
      type t = SPosition_15975123903786802361.t =
        | AmpSide
        | Center
        | SourceSide
        | Undefined of int
    end
    module TBreakdown = struct
      type t = TBreakdown_16560530708388719165.t =
        | None
        | Tipped
        | MechanicalFailure
        | Incapacitated
        | Undefined of int
    end
    module EClimb = struct
      type t = EClimb_13533464256854897024.t =
        | Success
        | Failed
        | DidNotAttempt
        | Harmony
        | Parked
        | Undefined of int
    end
    module RobotPosition = struct
      type t = RobotPosition_16615598200473616182.t =
        | Red1
        | Red2
        | Red3
        | Blue1
        | Blue2
        | Blue3
        | Undefined of int
    end
    module MatchAndPosition = struct
      type struct_t = [`MatchAndPosition_fcb71e38a70d3910]
      type t = struct_t builder_t
      let match_get x =
        BA_.get_int16 ~default:(0) x 0
      let match_set_exn x v =
        BA_.set_int16 ~default:(0) x 0 v
      let position_get x =
        let discr = BA_.get_uint16 ~default:0 x 2 in
        RobotPosition_16615598200473616182.decode discr
      let position_set x e =
        BA_.set_uint16 ~default:0 x 2 (RobotPosition_16615598200473616182.encode_safe e)
      let position_set_unsafe x e =
        BA_.set_uint16 ~default:0 x 2 (RobotPosition_16615598200473616182.encode_unsafe e)
      let of_message x = BA_.get_root_struct ~data_words:1 ~pointer_words:0 x
      let to_message x = x.BA_.NM.StructStorage.data.MessageWrapper.Slice.msg
      let to_reader x = Some (RA_.StructStorage.readonly x)
      let init_root ?message_size () =
        BA_.alloc_root_struct ?message_size ~data_words:1 ~pointer_words:0 ()
      let init_pointer ptr =
        BA_.init_struct_pointer ptr ~data_words:1 ~pointer_words:0
    end
    module MaybeError = struct
      type struct_t = [`MaybeError_db6aa7ecdb8f85bb]
      type t = struct_t builder_t
      let success_get x =
        BA_.get_bit ~default:false x ~byte_ofs:0 ~bit_ofs:0
      let success_set x v =
        BA_.set_bit ~default:false x ~byte_ofs:0 ~bit_ofs:0 v
      let has_message_if_error x =
        BA_.has_field x 0
      let message_if_error_get x =
        BA_.get_text ~default:"" x 0
      let message_if_error_set x v =
        BA_.set_text x 0 v
      let of_message x = BA_.get_root_struct ~data_words:1 ~pointer_words:1 x
      let to_message x = x.BA_.NM.StructStorage.data.MessageWrapper.Slice.msg
      let to_reader x = Some (RA_.StructStorage.readonly x)
      let init_root ?message_size () =
        BA_.alloc_root_struct ?message_size ~data_words:1 ~pointer_words:1 ()
      let init_pointer ptr =
        BA_.init_struct_pointer ptr ~data_words:1 ~pointer_words:1
    end
  end

  module Client = struct
  end

  module Service = struct
  end
  module MessageWrapper = MessageWrapper
end

module Make(M:Capnp.MessageSig.S) = MakeRPC(Capnp.RPC.None(M))
