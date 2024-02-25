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
      | Park
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
      val has_t_range : t -> bool
      val t_range_get : t -> string
      val tele_breakdown_get : t -> TBreakdown_16560530708388719165.t
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
        | Park
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
      val has_t_range : t -> bool
      val t_range_get : t -> string
      val t_range_set : t -> string -> unit
      val tele_breakdown_get : t -> TBreakdown_16560530708388719165.t
      val tele_breakdown_set : t -> TBreakdown_16560530708388719165.t -> unit
      val tele_breakdown_set_unsafe : t -> TBreakdown_16560530708388719165.t -> unit
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
        | Park
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

module MakeRPC(MessageWrapper : Capnp.RPC.S) : sig
  include S with module MessageWrapper = MessageWrapper

  module Client : sig
  end

  module Service : sig
  end
end

module Make(M : Capnp.MessageSig.S) : module type of MakeRPC(Capnp.RPC.None(M))
