#include "common.h"

/*
  Converts a `libspotify` error code to an actual message using `sp_error_message`.
  
  @param [Fixnum] errno
  @return [String]
*/
static VALUE eError_explain(VALUE self, VALUE errno)
{
  return rb_str_new2(sp_error_message(FIX2INT(errno)));
}

/*
  Thrown by Hallon on `libspotify` errors.
  
  @see http://developer.spotify.com/en/libspotify/docs/group__error.html
*/
void Init_Error(void)
{
  /* Tempvar for YARD */
  VALUE eError = rb_define_class_under(hn_mHallon, "Error", rb_eStandardError);
  rb_define_singleton_method(eError, "explain", eError_explain, 1);
}