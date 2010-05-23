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

/* --------------------- BEGIN SESSION CALLBACKS ---------------------*/

static void callback_logged_in(sp_session *session, sp_error error)
{
  //fprintf(stderr, "logged in: %s", sp_error_message(error));
}

static void callback_logged_out(sp_session *session)
{
  fprintf(stderr, "logged out");
}

static void callback_metadata_updated(sp_session *session)
{
  fprintf(stderr, "metadata updated");
}

static void callback_connection_error(sp_session *session, sp_error error)
{
  fprintf(stderr, "connection error: %s", sp_error_message(error));
}

static void callback_message_to_user(sp_session *session, const char *message)
{
  fprintf(stderr, "message to user: %s", message);
}

static void callback_notify_main_thread(sp_session *session)
{
  int timeout = -1;
  sp_session_process_events(session, &timeout);
}

static void callback_log_message(sp_session *session, const char *data)
{
  //rb_eval_string(sprintf("($log ||= []).push(\"%s\")", data));
}

static sp_session_callbacks g_callbacks =
{
  .logged_in = callback_logged_in, 
  .logged_out = callback_logged_out,
  .metadata_updated = callback_metadata_updated,
  .message_to_user = callback_message_to_user,
  .notify_main_thread = callback_notify_main_thread,
  .music_delivery = NULL,
  .play_token_lost = NULL,
  .log_message = callback_log_message,
  .end_of_track = NULL
};

/* ---------------------- END SESSION CALLBACKS ----------------------*/

/**
 * call-seq:
 *   Error.message(Fixnum) -> String
 * 
 * Convert an integer into a {spotify error message}[https://developer.spotify.com/en/libspotify/docs/group__error.html#g983dee341d3c2008830513b7cffe7bf3]
 */
static VALUE eError_message(VALUE klass, VALUE code)
{
  Check_Type(code, T_FIXNUM);
  return rb_str_new2(sp_error_message(FIX2INT(code)));
}

/**
 * call-seq:
 *   Session.allocate
 * 
 * Internal method. Do not use.
 */
static VALUE cSession_allocate(VALUE self)
{
  sp_session **psession;
  return Data_Make_Struct(self, sp_session*, 0, xfree, psession);
}

/**
 * call-seq:
 *   Session.instance(application_key, user_agent = 'Hallon', cache_path = 'tmp', settings_path = 'tmp')
 * 
 * Initializes the Session. The first argument should a string containing your application key. 
 * <br><br>
 * See sp_session_init[https://developer.spotify.com/en/libspotify/docs/group__session.html#ga3d50584480c8a5b554ba5d1b8d09b8b] for more details.
 */
static VALUE cSession_initialize(int argc, VALUE *argv, VALUE self)
{
  VALUE v_appkey, v_user_agent, v_cache_path, v_settings_path;
  
  // default arguments scanning
  switch (rb_scan_args(argc, argv, "13", &v_appkey, &v_user_agent, &v_cache_path, &v_settings_path))
  {
    case 1: v_user_agent = rb_str_new2("Hallon");
    case 2: v_cache_path = rb_str_new2("tmp");
    case 3: v_settings_path = rb_str_new2("tmp");
  }
  
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
    &g_callbacks, // callbacks
    NULL, // user supplied data
  };
  
  sp_session **psession;
  Data_Get_Struct(self, sp_session*, psession);
  sp_error error = sp_session_init(&config, &(*psession));
  
  if (error != SP_ERROR_OK)
  {
    rb_raise(eError, sp_error_message(error));
  }
  
  return Qnil;
}

/**
 * call-seq:
 *   session.logged_in? -> true or false
 * 
 * Returns true if the current session is logged in.
 */
static VALUE cSession_logged_in(VALUE self)
{
  sp_session **psession;
  Data_Get_Struct(self, sp_session*, psession);
  return (sp_session_connectionstate(*psession) == SP_CONNECTION_STATE_LOGGED_IN) ? Qtrue : Qfalse;
}

/**
 * call-seq:
 *   session.login(username, password) -> Session
 * 
 * Logs the user in to Spotify.
 */
static VALUE cSession_login(VALUE self, VALUE username, VALUE password)
{
  sp_session **psession;
  Data_Get_Struct(self, sp_session*, psession);
  
  sp_connectionstate state = sp_session_connectionstate(*psession);
  sp_error error = sp_session_login(*psession, StringValuePtr(username), StringValuePtr(password));
  
  if (SP_ERROR_OK != error)
  {
    rb_raise(eError, sp_error_message(error));
  }
  
  do
  {
    usleep(10);
  } while(sp_session_connectionstate(*psession) == state);
  
  return self;
}

void Init_hallon()
{
  mHallon = rb_define_module("Hallon");
    /* The libspotify version Hallon was compiled with. */
    rb_define_const(mHallon, "API_VERSION", INT2FIX(SPOTIFY_API_VERSION));
  
  // Error Exception
  eError = rb_define_class_under(mHallon, "Error", rb_eStandardError);
    //rb_define_singleton_method(eError, "message", eError_message, 1);
  
  // Session class
  cSession = rb_define_class_under(mHallon, "Session", rb_cObject);
  rb_define_alloc_func(cSession, cSession_allocate);
  rb_define_method(cSession, "initialize", cSession_initialize, -1);
  rb_define_method(cSession, "logged_in?", cSession_logged_in, 0);
  rb_define_method(cSession, "login", cSession_login, 2);
}