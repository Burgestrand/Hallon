#include <ruby.h>

#ifdef HAVE_LIBSPOTIFY_API_H
#  include <libspotify/api.h>
#else
#  include <spotify/api.h>
#endif

// API Hierarchy
static VALUE mHallon;

  static VALUE eError;


// Error exception
// ---------------------------------------------------------------------

/**
 * call-seq:
 *   Error.message(fixnum) -> string
 */
static VALUE eError_message(VALUE klass, VALUE code)
{
  Check_Type(code, T_FIXNUM);
  return rb_str_new2(sp_error_message(FIX2INT(code)));
}

// Extension initialization
void Init_hallon()
{
  // Top-level module
  mHallon = rb_define_module("Hallon");
  rb_define_const(mHallon, "API_VERSION", INT2FIX(SPOTIFY_API_VERSION));
  
  // Error exception
  eError = rb_define_class_under(mHallon, "Error", rb_eStandardError);
  rb_define_singleton_method(eError, "message", eError_message, 1);
}