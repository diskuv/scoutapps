#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>

extern value arithmetic_add(value a, value b) {
  return (Val_int(Int_val(a) + Int_val(b)));
}

extern value arithmetic_subtract(value a, value b) {
  return (Val_int(Int_val(a) - Int_val(b)));
}

extern value arithmetic_multiply(value a, value b) {
  return (Val_int(Int_val(a) * Int_val(b)));
}

extern double arithmetic_divide_native(int a, int b) {
  return Int_val(a) / (double) Int_val(b);
}

extern value arithmetic_divide_bytecode(value a, value b) {
  return caml_copy_double(arithmetic_divide_native(a, b));
}
