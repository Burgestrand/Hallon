#include "common.h"
#include "session.h"

/*
  Allocate space for a session pointer and attach it to the returned object.
*/
static VALUE cSession_alloc(VALUE klass)
{
  session_data_t *session_data = ALLOC(session_data_t);
  
  /* initialize */
  session_data->session_ptr = ALLOC(sp_session*);
  pthread_mutex_init(&session_data->event_mutex, NULL);
  pthread_cond_init(&session_data->event_signal, NULL);
  
  return Data_Wrap_Struct(klass, NULL, cSession_free, session_data);
}

/*
  Release the created session and deallocate the session pointer.
*/
static void cSession_free(session_data_t* session_data)
{
  /*
    NOTE: if `sp_session_create` fails the session_ptr will be NULL
    
    BUG: libspotify 0.0.6
    If a call has been made earlier to `sp_session_create` and it failed, this
    cleanup call will also fail with a segfault in `sp_image_create`.
  */
  // sp_session_release(*session_data->session_ptr);
  
  pthread_mutex_destroy(&session_data->event_mutex);
  pthread_cond_destroy(&session_data->event_signal);
  xfree(session_data);
}

/*
  call-seq: initialize(application_key, user_agent = "Hallon", settings_path = Dir.mktmpdir("se.burgestrand.hallon"), cache_path = settings_path)
  
  Creates a new Spotify session with the given parameters using `sp_session_create`.
  
  @note Until `libspotify` allows you to create more than one session, you must use {Session#instance} instead of this method
  @param [#to_s] application_key (binary)
  @param [#to_s] user_agent
  @param [#to_s] settings_path
  @param [#to_s] cache_path
*/
static VALUE cSession_initialize(int argc, VALUE *argv, VALUE self)
{
  VALUE appkey, user_agent, settings_path, cache_path;
  VALUE tmp_prefix = rb_str_new2("se.burgestrand.hallon");
  VALUE tmpdir = rb_funcall3(rb_cDir, rb_intern("mktmpdir"), 1, &tmp_prefix);
  
  switch (rb_scan_args(argc, argv, "13", &appkey, &user_agent, &settings_path, &cache_path))
  {
    case 1: user_agent    = rb_str_new2("Hallon");
    case 2: settings_path = tmpdir;
    case 3: cache_path    = settings_path;
  }
  
  /* readonly variables */
  rb_iv_set(self, "@application_key", appkey);
  rb_iv_set(self, "@user_agent", user_agent);
  rb_iv_set(self, "@settings_path", settings_path);
  rb_iv_set(self, "@cache_path", cache_path);
  
  extern sp_session_callbacks HALLON_SESSION_CALLBACKS; /* session_events.c */
  sp_session_callbacks callbacks = HALLON_SESSION_CALLBACKS;
  sp_session_config config =
  {
    .api_version          = SPOTIFY_API_VERSION,
    .cache_location       = StringValueCStr(cache_path),
    .settings_location    = StringValueCStr(settings_path),
    .application_key      = StringValuePtr(appkey),
    .application_key_size = RSTRING_LENINT(appkey),
    .user_agent           = StringValueCStr(user_agent),
    .callbacks            = &callbacks,
    .userdata             = DATA_OF(self),
    .tiny_settings        = true,
  };
  
  sp_error error = sp_session_create(&config, DATA_OF(self)->session_ptr);
  ASSERT_OK(error);
  
  /*
    Spawns event handling thread.
    
    @note Creating a session (`sp_session_create`) calls the notify callback
          instantly, but only once. The `rb_thread_blocking_region` call seems
          to schedule threads before it executes the blocking function.
          
          Hopefully, missing the first notify event won’t matter.
  */
  VALUE thread = rb_thread_create(session_event_handler, (void*) self);
  rb_iv_set(self, "@event_handler", thread);
  rb_thread_schedule();
  
  return self;
}

/*
  Retrieve the connection state for this session.
  
  @return [Symbol] `:logged_out`, `:logged_in`, `:disconnected` or `:undefined`
*/
static VALUE cSession_state(VALUE self)
{
  switch(sp_session_connectionstate(*DATA_OF(self)->session_ptr))
  {
    case SP_CONNECTION_STATE_LOGGED_OUT: return STR2SYM("logged_out");
    case SP_CONNECTION_STATE_LOGGED_IN: return STR2SYM("logged_in");
    case SP_CONNECTION_STATE_DISCONNECTED: return STR2SYM("disconnected");
    default: return STR2SYM("undefined");
  }
}

/*
  Processes Spotify events using `sp_session_process_events` until it no longer
  needs to do this.
  
  @private
  @return [Fixnum] milliseconds until {#process_events} should be called again
*/
static VALUE cSession_process_events(VALUE self)
{
  int timeout = 0;
  while(timeout == 0) sp_session_process_events(*DATA_OF(self)->session_ptr, &timeout);
  return INT2FIX(timeout);
}

/*
  Document-class: Hallon::Session
  
  The Session is fundamental for all communication with Spotify. Pretty much *all*
  API calls require you to have established a session with Spotify before
  using them.
  
  @see https://developer.spotify.com/en/libspotify/docs/group__session.html
*/
void Init_Session(void)
{
  rb_require("tmpdir");
  
  VALUE cSession = rb_define_class_under(MHallon, "Session", rb_cObject);
  rb_define_alloc_func(cSession, cSession_alloc);
  rb_define_method(cSession, "initialize", cSession_initialize, -1);
  rb_define_method(cSession, "state", cSession_state, 0);
  rb_define_method(cSession, "process_events", cSession_process_events, 0);
}