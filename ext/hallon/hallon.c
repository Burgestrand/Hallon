#include "common.h"

VALUE Hallon_Error;

void Init_hallon(void)
{
  VALUE mHallon = rb_define_module("Hallon");
  
  /*
    libspotify API version Hallon was compiled with
  */
  rb_define_const(mHallon, "API_VERSION", INT2FIX(SPOTIFY_API_VERSION));
  
  /*
    Hallon exception class, thrown on all Hallon-specific errors
  */
  Hallon_Error = rb_define_class_under(mHallon, "Error", rb_eStandardError);
  
  /* Initialize the other parts */
  Init_Session(mHallon);
  
  /* Require ruby part of Hallon */
  rb_require("hallon/hallon");
}