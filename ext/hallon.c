#include <ruby.h>

#ifdef HAVE_LIBSPOTIFY_API_H
#  include <libspotify/api.h>
#else
#  include <spotify/api.h>
#endif

// API Hierarchy
static VALUE mHallon;

// Extension initialization
void Init_hallon()
{
  // Top-level module
  mHallon = rb_define_module("Hallon");
  rb_define_const(mHallon, "API_VERSION", INT2FIX(SPOTIFY_API_VERSION));
}