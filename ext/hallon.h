#ifndef __HALLON__
  #define __HALLON__

  #include <ruby.h>
  #include <pthread.h>

  #ifdef HAVE_LIBSPOTIFY_API_H
  #  include <libspotify/api.h>
  #else
  #  include <spotify/api.h>
  #endif
  
  #define Data_Set_Ptr(obj, type, var) do {\
    Check_Type(obj, T_DATA);\
    *((type **) DATA_PTR(obj)) = var;\
  } while (0)

  // Statement Expressions: a gcc extension
  #define Data_Make_Obj(klass, type, ptr) ({\
    VALUE _obj = rb_funcall3(klass, rb_intern("allocate"), 0, NULL);\
    Data_Set_Ptr(_obj, type, ptr);\
    rb_funcall2(_obj, rb_intern("initialize"), 0, NULL);\
    _obj;\
  })

  #define DATA_PPTR(obj, type) ({\
    Check_Type(obj, T_DATA);\
    type *_type_ptr = *((type **) DATA_PTR(obj));\
    if ( ! _type_ptr)\
    {\
      rb_raise(eError, "Invalid %s* target", #type);\
    }\
    _type_ptr;\
  })
#endif