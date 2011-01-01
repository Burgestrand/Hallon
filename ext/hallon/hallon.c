#include "common.h"

/*
  The Hallon namespace contains all classes and modules to avoid polluting the
  global namespace.
  
  However, the goodies you are looking for are probably in the {Hallon::Session} class.
*/
void Init_hallon(void)
{
  rb_define_module("Hallon");
  
  /*
    libspotify API version Hallon was compiled with.
  */
  rb_define_const(hn_mHallon, "API_VERSION", INT2FIX(SPOTIFY_API_VERSION));
  
  /* Initialize the other parts */
  Init_Error();
  Init_Session();
}