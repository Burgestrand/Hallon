#ifndef __HALLON__
  #define __HALLON__
  
  #include <ruby.h>
  #include <pthread.h>
  #include <assert.h>
  
  #ifdef HAVE_LIBSPOTIFY_API_H
  #  include <libspotify/api.h>
  #else
  #  include <spotify/api.h>
  #endif
  
  #define STR2SYM(string) ID2SYM(rb_intern(string))
  #define true 1
  #define false 0
  
  #include "macros.h"
  
  /*
    Initializers for the other classes.
  */
  void Init_Session();
  
  /*
    Common accessors
  */
  #define MHallon rb_const_get(rb_cObject, rb_intern("Hallon"))
  #define EHallon rb_const_get(MHallon, rb_intern("Error"))
#endif