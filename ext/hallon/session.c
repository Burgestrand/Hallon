#include "common.h"
#include "events.h"
#include "callbacks.h"
#include "session.h"
#include "semaphore.h"

/*
  Prototypes
*/
static void cSession_s_free(hn_session_data_t*);
static VALUE sp_session_create_nogvl(void *);

static VALUE sp_session_process_events_nogvl(void *);
static VALUE sp_session_login_nogvl(void *);
static VALUE sp_session_logout_nogvl(void *);

/*
  Allocate space for a session pointer and attach it to the returned object.
*/
static VALUE cSession_s_alloc(VALUE klass)
{
  hn_session_data_t *session_data = ALLOC(hn_session_data_t);
  hn_event_t *event_ptr = ALLOC(hn_event_t);
  
  /* initialize */
  session_data->session_ptr = ALLOC(sp_session*);
  session_data->session_obj = Qnil;
  
  session_data->event_full  = hn_sem_init(0);
  session_data->event_empty = hn_sem_init(1);
  
  event_ptr->handler = NULL;
  event_ptr->data    = NULL;
  session_data->event = event_ptr;
  
  return Data_Wrap_Struct(klass, NULL, cSession_s_free, session_data);
}

/*
  Release the created session and deallocate the session pointer.
*/
static void cSession_s_free(hn_session_data_t* session_data)
{
  /*
    NOTE: if `sp_session_create` fails the session_ptr will be NULL
    
    BUG: libspotify 0.0.6
    If a call has been made earlier to `sp_session_create` and it failed, this
    cleanup call will also fail with a segfault in `sp_image_create`.
  */
  /* sp_session_release(*session_data->session_ptr); */
  
  /* TODO: make it kill event_producer thread */
  /* IDEA: do ^ by sending the event_producer thread a rb_thread_kill event :d */
  hn_sem_destroy(session_data->event_empty);
  hn_sem_destroy(session_data->event_full);
  
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
  hn_session_data_t *session_data = DATA_OF(self);
  session_data->session_obj    = self;
  
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
  
  /* Finally, the libspotify calls */
  sp_session_config config =
  {
    .api_version          = SPOTIFY_API_VERSION,
    .cache_location       = StringValueCStr(cache_path),
    .settings_location    = StringValueCStr(settings_path),
    .application_key      = StringValuePtr(appkey),
    .application_key_size = RSTRING_LENINT(appkey),
    .user_agent           = StringValueCStr(user_agent),
    .callbacks            = &HALLON_SESSION_CALLBACKS,
    .userdata             = session_data,
    .tiny_settings        = true,
  };
  
  /* @note This calls the `notify_main_thread` callback once from the same pthread. */
  void* pargs[] = { &config, session_data->session_ptr };
  sp_error error = (sp_error) hn_proc_without_gvl(sp_session_create_nogvl, pargs);
  ASSERT_OK(error);

  /* shared queue between consumer & producer */
  VALUE thargs[] = { self, rb_eval_string("Queue.new") };
  
  /* @see events.c and events.h */
  rb_iv_set(self, "@event_producer", rb_thread_create(event_producer, thargs));
  
  /* defined in hallon/session.rb */
  rb_funcall(self, rb_intern("spawn_consumer"), 1, thargs[1]);
  
  return self;
}

/* invokes notify_main_thread callback, ie. blocks until the event can be handled */
static VALUE sp_session_create_nogvl(void *_pargs)
{
  void **pargs = (void**) _pargs;
  return (VALUE) sp_session_create((sp_session_config*) pargs[0], (sp_session**) pargs[1]);
}

/*
  Retrieve the connection state for this session.
  
  @return [Symbol] `:logged_out`, `:logged_in`, `:disconnected` or `:undefined`
*/
static VALUE cSession_status(VALUE self)
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
  Processes Spotify events using `sp_session_process_events` until the returned
  timeout is > 0.
  
  @private
  @note Callbacks might be invoked as a side-effect of executing this method.
  @return [Fixnum] milliseconds until {#process_events} should be called again
*/
static VALUE cSession_process_events(VALUE self)
{
  int timeout = (int) hn_proc_without_gvl(sp_session_process_events_nogvl, *DATA_OF(self)->session_ptr);
  return INT2FIX(timeout);
}

/* this call might lead to trying to lock the event lock, so it is a blocking call */
static VALUE sp_session_process_events_nogvl(void *session_ptr)
{
  int timeout = 0;
  while(timeout == 0) sp_session_process_events((sp_session*) session_ptr, &timeout);
  return (VALUE) timeout;
}

/*
  Logs in to Spotify using the given account name and password.
  
  @param [#to_s] username
  @param [#to_s] password
  @return [Session]
*/
static VALUE cSession_login(VALUE self, VALUE username, VALUE password)
{
  hn_session_data_t *session_data = DATA_OF(self);
  void *argv[] = { *session_data->session_ptr, StringValueCStr(username), StringValueCStr(password) };
  sp_error error = (sp_error) hn_proc_without_gvl(sp_session_login_nogvl, argv);
  ASSERT_OK(error);
  return self;
}

/* just paranoia, actually */
static VALUE sp_session_login_nogvl(void *_argv)
{
  void **argv = (void**) _argv;
  return (VALUE) sp_session_login((sp_session*) argv[0], (char*) argv[1], (char*) argv[2]);
}

/*
  Fires an event, as if it was generated by `libspotify`.
  
  @param [Object, …] event data
  @return [Session]
*/
static VALUE cSession_fire_bang(VALUE self, VALUE argv)
{
  void *args[] = { *DATA_OF(self)->session_ptr, (void*) argv };
  hn_proc_without_gvl(hn_session_fire, args);
  return self;
}

/*
  Logs out of Spotify. Does nothing if not logged in.
  
  @raise [Hallon::Error] if libspotify returns an error
  @return [Session]
*/
static VALUE cSession_logout_bang(VALUE self)
{
  if (rb_funcall3(self, rb_intern("logged_in?"), 0, NULL) == Qtrue)
  {
    sp_error error = (sp_error) hn_proc_without_gvl(sp_session_logout_nogvl, *DATA_OF(self)->session_ptr);
    ASSERT_OK(error);
  }
  
  return self;
}

static VALUE sp_session_logout_nogvl(void *session_ptr)
{
  return (VALUE) sp_session_logot(session_ptr);
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
  rb_require("tmpdir"); // Session#initialize
  rb_require("thread"); // Session#initialize (Queue)
  
  VALUE cSession = rb_define_class_under(hn_mHallon, "Session", rb_cObject);
  rb_define_alloc_func(cSession, cSession_s_alloc);
  rb_define_method(cSession, "initialize", cSession_initialize, -1);
  rb_define_method(cSession, "status", cSession_status, 0);
  rb_define_method(cSession, "process_events", cSession_process_events, 0);
  rb_define_method(cSession, "login", cSession_login, 2);
  rb_define_method(cSession, "fire!", cSession_fire_bang, -2);
  rb_define_method(cSession, "logout!", cSession_logout_bang, 0);
}