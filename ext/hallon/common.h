#ifndef __HALLON__
  #define __HALLON__
  
  #include <ruby.h>
  #include <stdbool.h>
  #include <stdlib.h>
  #include <assert.h>
  #include <libspotify/api.h>
  
  #include "utils.h"
  
  /*
    Initializers for the other classes.
  */
  void Init_Error(void);
  void Init_Events(void);
  void Init_Session(void);
  void Init_Link(void);
  
  /*
    The data structure required for all Spotify objects.
  */
  typedef struct
  {
    VALUE  handler;
    void (**spotify_ptr);
  } hn_spotify_data_t;
  
  hn_spotify_data_t* hn_alloc_spotify_data_t(void);
  void hn_mark_spotify_data_t(hn_spotify_data_t*);
  
  #define Data_Build_SPData(klass, mark, free) ({\
    hn_spotify_data_t *data_ptr = hn_alloc_spotify_data_t();\
    Data_Wrap_Struct(klass, mark, free, data_ptr);\
  })
  
  #define spfree(func, data) do {\
    if ((data)->spotify_ptr && *(data)->spotify_ptr) { (func)(*(data)->spotify_ptr); }\
  } while(0)
  
  /*
    Common accessors
  */
  #define hn_mHallon rb_const_get(rb_cObject, rb_intern("Hallon"))
  #define hn_eError hn_const_get("Error")
  #define hn_const_get(name) rb_const_get(hn_mHallon, rb_intern(name))
  #define hn_eError_maybe_raise(error) rb_funcall(hn_eError, rb_intern("maybe_raise"), 1, INT2FIX((int) error))
  #define hn_cEvents_build_handler(subject, handler, block) rb_funcall(hn_const_get("Events"), rb_intern("proxy_build_handler"), 3, subject, handler, block)
#endif