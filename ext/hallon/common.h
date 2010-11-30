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
  
  /*
    Like Data_Make_Struct, but this makes a pointer to the struct pointer.
    @note This macro is based on Statement Expressions, a GCC extension.
  */
  #define Data_Make_Ptr(klass, type, mark, free) ({\
    type **type_ptr;\
    Data_Make_Struct(klass, type*, mark, free, type_ptr);\
  })
  
  /*
    Like Data_Get_Struct, but this returns the pointer.
    @note This macro is based on Statement Expressions, a GCC extension.
  */
  #define Data_Get_Ptr(obj, type) ({\
    type **type_ptr;\
    Data_Get_Struct(obj, type*, type_ptr);\
    type_ptr;\
  })
  
  /*
    Data_Get_Ptr, but returns the value instead of the pointer. Raises an error
    on a null pointer.
  */
  #define Data_Get_PVal(obj, type) ({\
    type **type_ptr = Data_Get_Ptr(obj, type);\
    ASSERT_NOT_EMPTY(type_ptr);\
    *type_ptr;\
  })
  
  /*
    Make sure we’re OK, or raise an error with the message.
  */
  #define ASSERT_OK(error) do {\
    if (error != SP_ERROR_OK) rb_raise(Hallon_Error, "%s", sp_error_message(error));\
  } while (0)
  
  /*
    Make sure the given pointer is not a null pointer.
  */
  #define ASSERT_NOT_EMPTY(ptr) do {\
    ASSERT_NOT_NULL(ptr);\
    ASSERT_NOT_NULL(*ptr);\
  } while (0)
  
  /*
    Make sure the given pointer is not a null pointer and that its’ value is not NULL.
  */
  #define ASSERT_NOT_NULL(ptr) do {\
    if (ptr == NULL) rb_raise(Hallon_Error, "%s is null", #ptr);\
  } while (0)
  
  /*
    Common Exception class, found in Hallon.c
  */
  extern VALUE Hallon_Error;

  /*
    Initializers for the other classes.
  */
  void Init_Session(VALUE);
#endif