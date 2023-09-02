[@@@ocaml.warning "-27-32-37-60"]

type ro = Capnp.Message.ro
type rw = Capnp.Message.rw

module type S = sig
  module MessageWrapper : Capnp.RPC.S
  type 'cap message_t = 'cap MessageWrapper.Message.t
  type 'a reader_t = 'a MessageWrapper.StructStorage.reader_t
  type 'a builder_t = 'a MessageWrapper.StructStorage.builder_t

  module Climb_17059552977753218409 : sig
    type t =
      | None
      | Docked
      | Engaged
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
      val incap_get : t -> bool
      val playing_defense_get : t -> bool
      val has_notes : t -> bool
      val notes_get : t -> string
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
      val incap_get : t -> bool
      val incap_set : t -> bool -> unit
      val playing_defense_get : t -> bool
      val playing_defense_set : t -> bool -> unit
      val has_notes : t -> bool
      val notes_get : t -> string
      val notes_set : t -> string -> unit
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

module MakeRPC(MessageWrapper : Capnp.RPC.S) : sig
  include S with module MessageWrapper = MessageWrapper

  module Client : sig
  end

  module Service : sig
  end
end

module Make(M : Capnp.MessageSig.S) : module type of MakeRPC(Capnp.RPC.None(M))
