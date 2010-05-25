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
    static VALUE aSessions = Qnil; // array of *all* session instances
  
  
/**
 * Helper methods
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

// runs a function in a thread, passes arg as second argument
static VALUE run_in_thread(VALUE (*block)(ANYARGS), VALUE *obj)
{
  return rb_block_call(rb_const_get(rb_cObject, rb_intern("Thread")), rb_intern("new"), 1, obj, block, Qnil);
}

// sleeps the current thread
static VALUE rb_sleep(double seconds)
{
  if (seconds == 0)
  {
    return rb_funcall(rb_cObject, rb_intern("sleep"), 0);
  }

  VALUE time = rb_float_new(seconds);
  return rb_funcall(rb_cObject, rb_intern("sleep"), 1, time);
}

// convert ruby type to string
static const char *rb2str(VALUE type)
{
  switch (TYPE(type))
  {
    case T_NIL: return "NIL";
    case T_OBJECT: return "OBJECT";
    case T_CLASS: return "CLASS";
    case T_MODULE: return "MODULE";
    case T_FLOAT: return "FLOAT";
    case T_STRING: return "STRING";
    case T_REGEXP: return "REGEXP";
    case T_ARRAY: return "ARRAY";
    case T_FIXNUM: return "FIXNUM";
    case T_HASH: return "HASH";
    case T_STRUCT: return "STRUCT";
    case T_BIGNUM: return "BIGNUM";
    case T_FILE: return "FILE";
    case T_TRUE: return "TRUE";
    case T_FALSE: return "FALSE";
    case T_DATA: return "DATA";
    case T_SYMBOL: return "SYMBOL";
  }
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * End helper methods
 **/

/**
 * call-seq:
 *   session.thread -> Thread
 * 
 * Retrieves the event-processing thread.
 */
static VALUE ciSession_thread(VALUE self)
{
  return rb_iv_get(self, "@thread");
}

/**
 * Internal method: wake up the processing thread.
 */
static VALUE ciSession_processor_wakeup(VALUE self)
{
  VALUE thread = ciSession_thread(self);
  return rb_funcall3(thread, rb_intern("wakeup"), 0, NULL);
}

/**
 * Frees the memory associated with a session.
 */
static void ciSession_free(sp_session **psession)
{
  // TODO: retrieve session thread and kill it?
  xfree(psession);
}

/**
 * Internal method: allocate a pointer to an sp_session.
 */
static VALUE ciSession_allocate(VALUE self)
{
  sp_session **psession;
  return Data_Make_Struct(self, sp_session*, 0, ciSession_free, psession);
}

/**
 * Internal method: process spotify events. Run this in a thread.
 */
static VALUE ciSession_processloop(VALUE self)
{
  // sleep forever
  rb_sleep(0);
  
  // when woken up, we do work!
  sp_session **psession;
  int timeout = -1;
  Data_Get_Struct(self, sp_session*, psession);

  do
  {
    sp_session_process_events(*psession, &timeout);
    rb_sleep((timeout + 1) / 1000); // +1 to avoid *forever sleep*
  } while(1);
  
  return Qtrue;
}

/**
 * call-seq:
 *   Session.list -> Array
 * 
 * Returns an array containing all session instances.
 */
static VALUE cSession_list(void)
{
  if (NIL_P(aSessions))
  {
    aSessions = rb_ary_new();
  }
  
  return aSessions;
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
  
  // make sure we have a block
  rb_need_block();
  
  Data_Get_Struct(self, sp_session*, psession);
  sp_connectionstate state = sp_session_connectionstate(*psession);
  
  // we cannot login if already logged in
  if (state == SP_CONNECTION_STATE_LOGGED_IN)
  {
    rb_raise(eError, "already logged in");
  }
  
  sp_error error = sp_session_login(*psession, StringValuePtr(username), StringValuePtr(password));
  if (SP_ERROR_OK != error)
  {
    rb_raise(eError, "%s", sp_error_message(error));
  }
  
  // this is an ugly hack, but yet pretty hack
  do
  {
    int timeout = -1;
    sp_session_process_events(*psession, &timeout);
    rb_sleep(0.05);
  } while (sp_session_connectionstate(*psession) == state);
  
  // yield!
  rb_yield(self);
  
  return self;
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

static VALUE ciSession_equal(VALUE self, VALUE other)
{
  sp_session **a, **b;
  Data_Get_Struct(self, sp_session*, a);
  Data_Get_Struct(self, sp_session*, b);
  return *a == *b;
}

/**
 * Begin session callbacks
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static void callback_notify(sp_session *session)
{
  fprintf(stderr, "\nINFO: notify main thread");
  //cSesson_list 
}

static void callback_logged_in(sp_session *session, sp_error error)
{
  fprintf(stderr, "\nINFO: logged in: %s", sp_error_message(error));
}
 
static void callback_log(sp_session *session, const char *data)
{
  fprintf(stderr, "\nLOG: %s", data);
}

static void callback_logged_out(sp_session *session)
{
  fprintf(stderr, "\nINFO: logged out");
}

static void callback_metadata_updated(sp_session *session)
{
  fprintf(stderr, "\nINFO: metadata updated");
}

static void callback_connection_error(sp_session *session, sp_error error)
{
  fprintf(stderr, "\nERROR: %s", sp_error_message(error));
}

static void callback_message_to_user(sp_session *session, const char *message)
{
  fprintf(stderr, "\nMESSAGE: %s", message);
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * End session callbacks
 **/

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
  sp_session **psession;
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
  
  // create an event processing thread
  VALUE processloop = run_in_thread(ciSession_processloop, &self);
  rb_iv_set(self, "@thread", processloop);
  
  // retrieve session pointer storage
  Data_Get_Struct(self, sp_session*, psession);
  
  // set callbacks
  sp_session_callbacks callbacks =
  {
    .logged_in = callback_logged_in, 
    .logged_out = callback_logged_out,
    .metadata_updated = callback_metadata_updated,
    .connection_error = callback_connection_error,
    .message_to_user = callback_message_to_user,
    .notify_main_thread = callback_notify,
    .music_delivery = NULL,
    .play_token_lost = NULL,
    .log_message = callback_log,
    .end_of_track = NULL
  };
  
  // set configuration
  sp_session_config config = 
  {
    SPOTIFY_API_VERSION,
    StringValuePtr(v_cache_path),
    StringValuePtr(v_settings_path),
    RSTRING_PTR(v_appkey),
    RSTRING_LEN(v_appkey),
    StringValuePtr(v_user_agent),
    &callbacks, // callbacks
    NULL, // user supplied data
  };

  sp_error error = sp_session_init(&config, &(*psession));
  
  if (error != SP_ERROR_OK)
  {
    // kill and remove thread
    rb_funcall3(processloop, rb_intern("kill"), 0, NULL);
    rb_iv_set(self, "@thread", Qnil);
    rb_raise(eError, "%s", sp_error_message(error));
  }
  
  // add self to available instances
  rb_ary_unshift(cSession_list(), self);
  
  return Qnil;
}

void Init_hallon()
{
  mHallon = rb_define_module("Hallon");
    /* The libspotify version Hallon was compiled with. */
    rb_define_const(mHallon, "API_VERSION", INT2FIX(SPOTIFY_API_VERSION));
  
  // Error Exception
  eError = rb_define_class_under(mHallon, "Error", rb_eStandardError);
  
  // Session class
  cSession = rb_define_class_under(mHallon, "Session", rb_cObject);
  rb_define_alloc_func(cSession, ciSession_allocate);
  rb_define_method(cSession, "initialize", cSession_initialize, -1);
  rb_define_method(cSession, "logged_in?", cSession_logged_in, 0);
  rb_define_method(cSession, "login", cSession_login, 2);
  rb_define_singleton_method(cSession, "list", cSession_list, 0);
}