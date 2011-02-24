#ifndef UTILS_H_PUO0POGY
#define UTILS_H_PUO0POGY

/*
  This header defines useful functions and shortcuts commonly used throughout
  the Hallon source code.
*/

/*
  Hallon utility functions.
*/
#include "link.h"

/*
  Ruby C API extensions.
*/
VALUE hn_proc_without_gvl(rb_blocking_function_t *, void *);
VALUE hn_funcall4(VALUE, ID, VALUE);
VALUE hn_hash_lookup_sym(VALUE, const char *);

/*
  Macros
*/

#ifndef NDEBUG
#  define DEBUG(msg) fprintf(stderr, "%s:%u: %s\n", __FILE__, __LINE__, msg)
#  define DUMP(fmt, x) fprintf(stderr, "%s:%u: %s = " fmt "\n", __FILE__, __LINE__, #x, x)
#else
#  define DEBUG(msg) /* noop */
#  define DUMP(fmt, x) /* noop */
#endif

#ifndef MIN
#  define MIN(a, b) (((a) < (b)) ? (a) : (b))
#endif

#define STR2SYM(string) ID2SYM(rb_intern(string))

#define Data_Fetch_Struct(obj, type) ({\
  type *type_ptr;\
  Data_Get_Struct(obj, type, type_ptr);\
  type_ptr;\
})

#define Data_Build_Struct(klass, type, mark, free) ({\
  type *type_ptr;\
  Data_Make_Struct(klass, type, mark, free, type_ptr);\
})

#define OMGWTF(msg) do {\
  fprintf(stderr, "%s:%d: %s", __FILE__, __LINE__, msg);\
  abort();\
} while(0)

#endif /* end of include guard: UTILS_H_PUO0POGY */