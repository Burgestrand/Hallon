#include <ruby.h>

#ifdef HAVE_LIBSPOTIFY_API_H
  // (most likely) Mac OS
  #include <libspotify/api.h>
#else
  #include <spotify/api.h>
#endif