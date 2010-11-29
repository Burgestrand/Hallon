#include "hallon.h"

void Init_hallon(void)
{
  VALUE mHallon;
  
  mHallon = rb_define_module("Hallon");
    /* libspotify version Hallon was compiled with */
    rb_define_const(mHallon, "API_VERSION", INT2FIX(SPOTIFY_API_VERSION));
}