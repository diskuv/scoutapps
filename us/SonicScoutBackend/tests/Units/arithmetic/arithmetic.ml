external add : int -> int -> int = "arithmetic_add"
external subtract : int -> int -> int = "arithmetic_subtract"
external multiply : int -> int -> int = "arithmetic_multiply"

external divide : int -> int -> (float[@unboxed])
  = "arithmetic_divide_bytecode" "arithmetic_divide_native"
  [@@noalloc]
