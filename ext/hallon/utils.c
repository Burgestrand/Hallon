#include "common.h"
#include "utils.h"

/*
  Release the GVL, call `fn` and re-acquire the GVL. No rb_* functions may be
  called within `fn`. Returns whatever the `fn` function returns.
  
  @note Any function passed here must be interruptible by RUBY_UBF_PROCESS
  @param [rb_blocking_function_t] fn
  @param [void*] data
  @return [VALUE]
*/
VALUE hn_proc_without_gvl(rb_blocking_function_t *fn, void *data)
{
  return rb_thread_blocking_region(fn, data, RUBY_UBF_PROCESS, NULL);
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
  Lock the given mutex, but do so without holding the GVL while waiting to lock.
  
  @param [pthread_mutex_t*] mutex
  @return [Fixnum] (see pthread_mutex_lock)
*/
static VALUE mutex_lock_nogvl(void *mutex) // without GVL
{
  return (VALUE) pthread_mutex_lock((pthread_mutex_t*) mutex);
}
VALUE pthread_mutex_lock_nogvl(pthread_mutex_t *mutex)
{
  return INT2FIX(hn_proc_without_gvl(mutex_lock_nogvl, mutex));
}

/*
  Wait for a signal on the given condition variable without holding the GVL.
  
  @param [pthread_cond_t*] cond
  @return [Fixnum] (see pthread_cond_wait)
*/
static VALUE cond_wait_nogvl(void *data) // without_gvl
{
  void **args = data;
  return (VALUE) pthread_cond_wait((pthread_cond_t*) args[0], (pthread_mutex_t*) args[1]);
}
VALUE pthread_cond_wait_nogvl(pthread_cond_t *cond, pthread_mutex_t *mutex)
{
  void *args[] = { cond, mutex };
  return INT2FIX(hn_proc_without_gvl(cond_wait_nogvl, args));
}

/*
  Signal the given condition variable without holding the GVL.
  
  @param [pthread_cond_t*] cond
  @param [pthread_mutex_t*] mutex
  @return [Fixnum] (see pthread_cond_signal)
*/
static VALUE cond_signal_nogvl(void *cond)
{
  return (VALUE) pthread_cond_signal((pthread_cond_t*) cond);
}
VALUE pthread_cond_signal_nogvl(pthread_cond_t *cond)
{
  return INT2FIX(hn_proc_without_gvl(cond_signal_nogvl, cond));
}