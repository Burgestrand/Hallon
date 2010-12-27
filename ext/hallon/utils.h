#ifndef UTILS_H_PUO0POGY
#define UTILS_H_PUO0POGY
/*
  This header defines useful functions and shortcuts commonly used throughout
  the Hallon source code.
*/

/*
  Ruby C API extensions.
*/
VALUE hn_proc_without_gvl(rb_blocking_function_t *fn, void *data);
VALUE hn_funcall4(VALUE, ID, VALUE);

/*
  Non-GVL versions of blocking C functions.
*/

// pthread
VALUE pthread_mutex_lock_nogvl(pthread_mutex_t*);
VALUE pthread_cond_wait_nogvl(pthread_cond_t*, pthread_mutex_t*);

/*
  Macros
*/

#ifndef NDEBUG
#  define DEBUG(msg) fprintf(stderr, "%s:%d -> %s\n", __FILE__, __LINE__, msg)
#  define DEBUG_N(msg, n) fprintf(stderr, "%s:%d -> (#%d) %s\n", __FILE__, __LINE__, n, msg)
#else
#  define DEBUG(msg) /* noop */
#endif

#define STR2SYM(string) ID2SYM(rb_intern(string))
#define ASSERT_OK(error) if (error != SP_ERROR_OK) rb_raise(EHallon, "%s", sp_error_message(error))

#define Data_Fetch_Struct(obj, type) ({\
  type *type_ptr;\
  Data_Get_Struct(obj, type, type_ptr);\
  type_ptr;\
})

#endif /* end of include guard: UTILS_H_PUO0POGY */