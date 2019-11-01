#include <ruby/ruby.h>

static VALUE baz_f_baz(VALUE self) {
  return INT2FIX(42);
}

void Init_baz() {
  rb_define_global_function("baz", baz_f_baz, 0);
}
