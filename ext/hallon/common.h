#ifndef __HALLON__
  #define __HALLON__
  
  #include <ruby.h>
  #include <pthread.h>
  
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
    Common Exception class, found in Hallon.c
  */
  extern VALUE Hallon_Error;

  /*
    Initializers for the other classes.
  */
  void Init_Session(VALUE);
#endif