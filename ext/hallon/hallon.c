#include "common.h"

void Init_hallon_ext(void)
{
  VALUE mHallon = rb_define_module("Hallon");
  
  /*
    libspotify API version Hallon was compiled with.
  */
  rb_define_const(mHallon, "API_VERSION", INT2FIX(SPOTIFY_API_VERSION));
  
  /* Initialize the other parts */
  Init_Error();
  Init_Base();
  Init_Session();
  Init_Link();
}