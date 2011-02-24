#include "common.h"
#include "utils.h"

/*
  Release the GVL, call `fn` and re-acquire the GVL. No rb_* functions may be
  called within `fn`. Returns whatever the `fn` function returns.
  
  @note This will tell Ruby that the process is ununblockable. Careful using this.
  @param [rb_blocking_function_t] fn
  @param [void*] data
  @return [VALUE]
*/
VALUE hn_proc_without_gvl(rb_blocking_function_t *fn, void *data)
{
  return rb_thread_blocking_region(fn, data, NULL /* not unblockable */, NULL);
}

/*
  Call a ruby method `ID` on receiver `recv` with array `argv` as arguments.
  It’s pretty much an `rb_apply` but using `rb_funcall3` internally.
  
  @param [VALUE] receiver
  @param [ID] method
  @param [Array]
*/
VALUE hn_funcall4(VALUE recv, ID msg, VALUE args)
{
  int argc = RARRAY_LENINT(args);
  VALUE *argv = ALLOCA_N(VALUE, argc);
  MEMCPY(argv, RARRAY_PTR(args), VALUE, argc);
  VALUE result = rb_funcall3(recv, msg, argc, argv);
  return result;
}

/*
  Look up a symbol key in a Hash, returning nil if not found.
  
  @param [VALUE] receiver
  @param [String] key
*/
VALUE hn_hash_lookup_sym(VALUE hash, const char *key)
{
  return rb_hash_lookup(hash, STR2SYM(key));
}