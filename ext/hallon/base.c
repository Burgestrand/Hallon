#include "common.h"

/*
  Deallocate the internal C structure to this Spotify object.
*/
static void cBase_s_free(hn_spotify_data_t *ptr)
{
  if (ptr->free_func && ptr->spotify_ptr && *ptr->spotify_ptr)
  {
    ptr->free_func(ptr->spotify_ptr);
  }
  
  xfree(ptr->spotify_ptr);
  xfree(ptr);
}

/*
  Allocate the internal C structure to this Spotify object.
  
  @note Classes that inherit from Hallon::Base must define their own free.
*/
static VALUE cBase_s_alloc(VALUE klass)
{
  hn_spotify_data_t *ptr = ALLOC(hn_spotify_data_t);
  ptr->spotify_ptr = ALLOC(void*);
  ptr->free_func   = NULL;
  ptr->handler     = Qnil;
  return Data_Wrap_Struct(klass, NULL, cBase_s_free, ptr);
}

/*
  Associate the current object to the internal Spotify C structure,
  making the object itself handle its’ own events.
*/
static VALUE cBase_initialize(VALUE self)
{
  ((hn_spotify_data_t*) DATA_PTR(self))->handler = self;
  
  if (rb_block_given_p())
  {
    VALUE proc = rb_eval_string("proc { |o, b| o.instance_eval(&b) }");
    rb_funcall(proc, rb_intern("call"), 2, self, rb_block_proc());
  }
  
  return self;
}

/*
  
*/
void Init_Base(void)
{
  VALUE cBase = rb_define_class_under(hn_mHallon, "Base", rb_cObject);
  rb_define_alloc_func(cBase, cBase_s_alloc);
  rb_define_method(cBase, "initialize", cBase_initialize, 0);
}