#include "common.h"

void Init_hallon(void)
{
  mHallon = rb_define_module("Hallon");
  
  /*
    libspotify API version Hallon was compiled with
  */
  rb_define_const(mHallon, "API_VERSION", INT2FIX(SPOTIFY_API_VERSION));
  
  // Require ruby part of Hallon
  rb_require("hallon/hallon");
}