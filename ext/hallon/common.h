#ifndef __HALLON__
  #define __HALLON__
  
  #include <ruby.h>
  #include <stdbool.h>
  #include <stdlib.h>
  
  #ifdef HAVE_LIBSPOTIFY_API_H
  #  include <libspotify/api.h>
  #else
  #  include <spotify/api.h>
  #endif
  
  #include "utils.h"
  
  /*
    Initializers for the other classes.
  */
  void Init_Session();
  
  /*
    Common accessors
  */
  #define hn_mHallon rb_const_get(rb_cObject, rb_intern("Hallon"))
  #define hn_cError hn_const_get("Error")
  #define hn_const_get(name) rb_const_get(hn_mHallon, rb_intern(name))
#endif