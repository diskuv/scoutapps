open DkSDKFFI_OCaml
open ComStandardSchema.Make(ComMessage.C)

val register_objects :
  ( Capnp.MessageSig.rw message_t,
    Capnp.MessageSig.ro MessageWrapper.Slice.t option )
  Com.t ->
  unit
