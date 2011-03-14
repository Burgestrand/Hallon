#include "common.h"

#define LINKPTR_OF(obj) *Data_Fetch_Struct(obj, sp_link*)

/*
  Prototypes.
*/
static void cLink_s_free(sp_link**);

/*
  Create a Link without calling #initialize. Useful for constructing links out
  of other objects.
*/
VALUE hn_cLink_create(sp_link *link_ptr)
{
  VALUE obj = rb_funcall3(hn_const_get("Link"), rb_intern("allocate"), 0, NULL);
  LINKPTR_OF(obj) = link_ptr;
  return obj;
}

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
  if (link_ptr && *link_ptr) sp_link_release(*link_ptr);
  xfree(link_ptr);
}

/*  
  @overload initialize(spotify_uri)
    Create a Link object from a given Spotify URI.
  
    @note Unless you have a {Hallon::Session} created, `libspotify` will segfault!
    @param [#to_s] spotify_uri
    @raise [ArgumentError] if the link could not be parsed
*/
static VALUE cLink_initialize(VALUE self, VALUE str)
{
  char *link = StringValueCStr(str);
  sp_link *link_ptr = LINKPTR_OF(self) = sp_link_create_from_string(link);
  
  if (link_ptr == NULL)
  {
    rb_raise(rb_eArgError, "“%s” is not a valid Spotify URI", link);
  }
  
  return self;
}

/*
  @overload to_str(length = length)
    Spotify URI of this Link.
    
    @param [Fixnum] length maximum length of string to return (default: {#length})
    @return [String]
*/
static VALUE cLink_to_str(int argc, VALUE *argv, VALUE self)
{
  VALUE length = Qnil;
  VALUE uri = Qnil;
  int buffsize = 0;
  char *buffer = NULL;
  
  rb_scan_args(argc, argv, "01", &length);
  
  if (NIL_P(length))
  {
    length = rb_funcall3(self, rb_intern("length"), 0, NULL);
  }
  
  buffer = ALLOC_N(char, buffsize = FIX2INT(length) + 1);
  sp_link_as_string(LINKPTR_OF(self), buffer, buffsize);
  uri = rb_str_new2(buffer);
  xfree(buffer);
  return uri;
}

/*
  Length of the underlying Spotify URI.
  
  @return [Fixnum]
*/
static VALUE cLink_length(VALUE self)
{
  return INT2FIX(sp_link_as_string(LINKPTR_OF(self), NULL, 0));
}

/*
  Link type
  
  @return [Symbol]
*/
static VALUE cLink_type(VALUE self)
{
  static const char * LINK_TYPES[] = {
    "invalid", "track", "album", "artist", "search", "playlist", "profile", "starred", "local"
  };
  
  return STR2SYM(LINK_TYPES[sp_link_type(LINKPTR_OF(self))]);
}

void Init_Link(void)
{
  VALUE cLink = rb_define_class_under(hn_mHallon, "Link", rb_cObject);
  rb_define_alloc_func(cLink, cLink_s_alloc);
  rb_define_method(cLink, "initialize", cLink_initialize, 1);
  rb_define_method(cLink, "to_str", cLink_to_str, -1);
  rb_define_method(cLink, "length", cLink_length, 0);
  rb_define_method(cLink, "type", cLink_type, 0);
}