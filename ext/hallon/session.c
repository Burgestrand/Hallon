#include "common.h"

void Init_Session(VALUE mHallon)
{
  VALUE cSession = rb_define_class_under(mHallon, "Session", rb_cObject);
}