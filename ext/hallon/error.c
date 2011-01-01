#include "common.h"

/*
  Converts a `libspotify` error code to an actual message using `sp_error_message`.
  
  @param [Fixnum] errno
  @return [String]
*/
static VALUE cError_explain(VALUE self, VALUE errno)
{
  return rb_str_new2(sp_error_message(FIX2INT(errno)));
}

/*
  Thrown by Hallon on critical Spotify errors.
*/
void Init_Error(void)
{
  rb_define_class_under(hn_mHallon, "Error", rb_eStandardError);
  rb_define_singleton_method(hn_cError, "explain", cError_explain, 1);
}