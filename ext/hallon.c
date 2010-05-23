#include <ruby.h>

#ifdef HAVE_LIBSPOTIFY_API_H
#  include <libspotify/api.h>
#else
#  include <spotify/api.h>
#endif

// API Hierarchy
static VALUE mHallon;

  // Error exception
  static VALUE eError;
  
  // Classes
  static VALUE cSession;


// Error exception
// ---------------------------------------------------------------------

/**
 * call-seq:
 *   Error.message(fixnum) -> string
 */
static VALUE eError_message(VALUE klass, VALUE code)
{
  Check_Type(code, T_FIXNUM);
  return rb_str_new2(sp_error_message(FIX2INT(code)));
}

// Session class
// ---------------------------------------------------------------------

/**
 * call-seq:
 *   Session.new(appkey, user_agent = 'Hallon', cache_path = 'tmp', settings_path = 'tmp')
 * 
 * Creates a new session object.
 */
static VALUE cSession_initialize(int argc, VALUE *argv, VALUE self)
{
  VALUE v_appkey, v_user_agent, v_cache_path, v_settings_path;
  
  // default arguments scanning
  rb_scan_args(argc, argv, "13", &v_appkey, &v_user_agent, &v_cache_path, &v_settings_path);
  
  // set default arguments
  if (NIL_P(v_user_agent)) v_user_agent = rb_str_new2("Hallon");
  if (NIL_P(v_cache_path)) v_cache_path = rb_str_new2("tmp");
  if (NIL_P(v_settings_path)) v_settings_path = rb_str_new2("tmp");
  
  // check argument types
  Check_Type(v_appkey, T_STRING);
  Check_Type(v_user_agent, T_STRING);
  Check_Type(v_cache_path, T_STRING);
  Check_Type(v_settings_path, T_STRING);
  
  sp_session_config config = 
  {
    SPOTIFY_API_VERSION,
    StringValuePtr(v_cache_path),
    StringValuePtr(v_settings_path),
    RSTRING(v_appkey)->ptr,
    RSTRING(v_appkey)->len,
    StringValuePtr(v_user_agent),
    NULL, // callbacks
    NULL, // user supplied data
  };
  
  sp_session *session = NULL;
  sp_error error = sp_session_init(&config, &session);
  
  if (error != SP_ERROR_OK)
  {
    rb_raise(eError, sp_error_message(error));
    return Qnil;
  }
  
  return Data_Wrap_Struct(cSession, NULL, NULL /* sp_session_release */, session);
}

// Extension initialization
void Init_hallon()
{
  // Top-level module
  mHallon = rb_define_module("Hallon");
  rb_define_const(mHallon, "API_VERSION", INT2FIX(SPOTIFY_API_VERSION));
  
  // Error exception
  eError = rb_define_class_under(mHallon, "Error", rb_eStandardError);
  rb_define_singleton_method(eError, "message", eError_message, 1);
  
  // Session class
  cSession = rb_define_class_under(mHallon, "Session", rb_cObject);
  //rb_define_alloc_func(cSession, cSession_allocate);
  rb_define_method(cSession, "initialize", cSession_initialize, -1);
}