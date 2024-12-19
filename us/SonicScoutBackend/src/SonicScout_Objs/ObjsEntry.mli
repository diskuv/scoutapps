open DkSDKFFI_OCaml
open ComStandardSchema.Make(ComMessageC)
   
val register_objects :
  ( Capnp.MessageSig.rw message_t,
    Capnp.MessageSig.ro MessageWrapper.Slice.t option )
  Com.t ->
  unit

include DkCoder_Std.SCRIPT
