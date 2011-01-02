#include "common.h"

#define LINKPTR_OF(obj) *Data_Fetch_Struct(obj, sp_link*)

/*
  Prototypes.
*/
static void cLink_s_free(sp_link**);

/*
  Allocate space for an sp_link* and attach it.
*/
static VALUE cLink_s_alloc(VALUE klass)
{
  return Data_Build_Struct(klass, sp_link*, NULL, cLink_s_free);
}

/*
  Release an allocated sp_link*, but only if it’s not a NULL-pointer (handled by xfree).
*/
static void cLink_s_free(sp_link **link_ptr)
{
  xfree(link_ptr);
}

/*
  call-seq: initialize(spotify_uri)
  
  Create a Link object from a given Spotify URI.
  
  @param [#to_s] spotify_uri
  @raise [ArgumentError] if the link could not be parsed
*/
static VALUE cLink_initialize(VALUE self, VALUE str)
{
  char *link = StringValueCStr(str);
  sp_link *link_ptr = LINKPTR_OF(self) = sp_link_create_from_string(link);
  
  if ( ! link_ptr)
  {
    rb_raise(rb_eArgError, "“%s” is not a valid Spotify URI", link);
  }
  
  return self;
}

void Init_Link(void)
{
  VALUE cLink = rb_define_class_under(hn_mHallon, "Link", rb_cObject);
  rb_define_alloc_func(cLink, cLink_s_alloc);
  rb_define_method(cLink, "initialize", cLink_initialize, 1);
}