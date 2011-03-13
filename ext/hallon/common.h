#ifndef __HALLON__
  #define __HALLON__
  
  #include <ruby.h>
  #include <stdbool.h>
  #include <stdlib.h>
  #include <assert.h>
  #include <libspotify/api.h>
  
  #include "base.h"
  #include "utils.h"
  
  # if SPOTIFY_API_VERSION != 7
  #   error Hallon only officially supports libspotify v0.0.7
  # endif
  
  /*
    Initializers for the other classes.
  */
  void Init_Error(void);
  void Init_Base();
  void Init_Session(void);
  void Init_Link(void);
  
  /*
    Common accessors
  */
  #define hn_mHallon rb_const_get(rb_cObject, rb_intern("Hallon"))
  #define hn_eError hn_const_get("Error")
  #define hn_cBase hn_const_get("Base")
  #define hn_const_get(name) rb_const_get(hn_mHallon, rb_intern(name))
  #define hn_eError_maybe_raise(error) rb_funcall(hn_eError, rb_intern("maybe_raise"), 1, INT2FIX((int) error))
#endif