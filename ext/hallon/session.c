#include "common.h"
#include "events.h"
#include "callbacks.h" /* hn_session_fire */

/* GLOBAL: events.c */
extern hn_event_t * g_event;

/*
  Useful macros :D
*/
#define SESSPTR_OF(obj) *((sp_session**) DATA_OF(obj)->spotify_ptr)
#define DATA_OF(obj) Data_Fetch_Struct(obj, hn_spotify_data_t)

/*
  Prototypes
*/
static void cSession_s_mark(hn_spotify_data_t*);
static void cSession_s_free(hn_spotify_data_t*);

static VALUE sp_session_process_events_nogvl(void *);
static VALUE sp_session_login_nogvl(void *);
static VALUE sp_session_logout_nogvl(void *);

/*
  Allocate space for a session pointer and attach it to the returned object.
  
  @note Also populates the global `g_event` variable!
*/
static VALUE cSession_s_alloc(VALUE klass)
{
  g_event = ALLOC(hn_event_t);
  g_event->sem_empty  = hn_sem_init(1);
  g_event->sem_full   = hn_sem_init(0);
  g_event->rb_handler = Qnil;
  g_event->c_handler  = NULL;
  g_event->c_data     = NULL;
  
  return Data_Build_SPData(klass, hn_mark_spotify_data_t, cSession_s_free);
}

/*
  Release the created session and deallocate the session pointer.
  
  @note if `sp_session_create` the spotify_ptr will be null
  @note libspotify 0.0.6 segfaults randomly on `sp_session_release`
*/
static void cSession_s_free(hn_spotify_data_t* session_data)
{
  spfree(sp_session_release, session_data);
  xfree(session_data);
}

/*
  call-seq: initialize(appkey, options = {}, &block)

  Creates a new Spotify session with the given parameters using `sp_session_create`.
  
  @example 
     session = Hallon::Session.new(appkey, :settings_path => "tmp") do
       def logged_in
         puts "We logged in successfully. Lets bail!"
         exit
       end
     end
  
  @note Until `libspotify` allows you to create more than one session, you must
        use {Hallon::Session#instance} instead of this method.
  @note Available options can be seen in Session#merge_defaults (don’t know why
        they don’t show up here).
  
  @param [#to_s] appkey your `libspotify` application key.
  @param [Hash] options additional options (see #merge_defaults)
  @param [Block] block will be evaluated within a handler context (see example)
  @option options [String] :user_agent ("Hallon") libspotify user agent
  @option options [String] :settings_path (".") path to save settings to
  @option options [String] :cache_path ("") location where spotify writes cache
  @raise [ArgumentError] if the :user_agent is > 255 characters long
  @see Hallon::Events
  @see Hallon::Events::build_handler
  @see Session#merge_defaults
  
  @overload initialize(appkey, handler, options = {}, &block)
    The given `handler` should include Hallon::Events, or be a module.
    
    @param [Class<Hallon::Events>, Module, nil] handler
*/
static VALUE cSession_initialize(int argc, VALUE *argv, VALUE self)
{
  VALUE appkey, handler, options, block;
  hn_spotify_data_t *session_data = DATA_OF(self);
  
  // Handle arguments, swapping if necessary
  rb_scan_args(argc, argv, "12&", &appkey, &handler, &options, &block);
  if (TYPE(handler) == T_HASH) { options = handler; handler = Qnil; }
  
  options = rb_funcall(self, rb_intern("merge_defaults"), 1, options);
  session_data->handler = hn_cEvents_build_handler(self, handler, block);
  
  /* options variables */
  VALUE user_agent    = rb_hash_lookup(options, STR2SYM("user_agent")),
        settings_path = rb_hash_lookup(options, STR2SYM("settings_path")),
        cache_path    = rb_hash_lookup(options, STR2SYM("cache_path"));
  
  // user_agent: max 255 characters long
  if (rb_str_strlen(user_agent) > 255)
  {
    rb_raise(rb_eArgError, "User-Agent may not be more than 255 characters");
  }
  
  /*
    Finally, we do the libspotify dance and spawn our threads.
  */
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
  sp_error error = sp_session_create(&config, (sp_session**) session_data->spotify_ptr);
  hn_eError_maybe_raise(error);
  
  /* spawn the event producer & consumer */
  VALUE threads = rb_funcall2(hn_const_get("Events"), rb_intern("spawn_handlers"), 0, NULL);
  
  rb_iv_set(self, "@threads", threads);
  rb_iv_set(self, "@appkey", appkey);
  rb_iv_set(self, "@options", options);
  
  return self;
}

/*
  Retrieve the connection state for this session.
  
  @return [Symbol] `:logged_out`, `:logged_in`, `:disconnected` or `:undefined`
*/
static VALUE cSession_status(VALUE self)
{
  switch(sp_session_connectionstate(SESSPTR_OF(self)))
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
  int timeout = (int) hn_proc_without_gvl(sp_session_process_events_nogvl, SESSPTR_OF(self));
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
  void *argv[] = { SESSPTR_OF(self), StringValueCStr(username), StringValueCStr(password) };
  sp_error error = (sp_error) hn_proc_without_gvl(sp_session_login_nogvl, argv);
  hn_eError_maybe_raise(error);
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
  
  @param [Object] receiver
  @param [Symbol] method
  @param [Object, …] arguments
  @return [Session]
*/
static VALUE cSession_fire_bang(int argc, VALUE *argv, VALUE self)
{
  VALUE recv, method, brgs;
  rb_scan_args(argc, argv, "2*", &recv, &method, &brgs);
  
  if ( ! SYMBOL_P(method))
  {
    rb_raise(rb_eArgError, "second argument must be a symbol");
  }
  
  void *args[] = { (void*) recv, (void*) rb_ary_unshift(brgs, method) };
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
    sp_error error = (sp_error) hn_proc_without_gvl(sp_session_logout_nogvl, SESSPTR_OF(self));
    hn_eError_maybe_raise(error);
  }
  
  return self;
}

static VALUE sp_session_logout_nogvl(void *session_ptr)
{
  return (VALUE) sp_session_logout(session_ptr);
}

/*
  Retrieve the handler to the associated session.
  
  @return [Hallon::Events]
*/
static VALUE cSession_handler(VALUE self)
{
  return DATA_OF(self)->handler;
}

/*
  The Session is fundamental for all communication with Spotify. Pretty much *all*
  API calls require you to have established a session with Spotify before
  using them.
  
  @see https://developer.spotify.com/en/libspotify/docs/group__session.html
*/
void Init_Session(void)
{
  VALUE cSession = rb_define_class_under(hn_mHallon, "Session", rb_cObject);
  rb_define_alloc_func(cSession, cSession_s_alloc);
  rb_define_method(cSession, "initialize", cSession_initialize, -1);
  rb_define_method(cSession, "status", cSession_status, 0);
  rb_define_method(cSession, "process_events", cSession_process_events, 0);
  rb_define_method(cSession, "login", cSession_login, 2);
  rb_define_method(cSession, "fire!", cSession_fire_bang, -1);
  rb_define_method(cSession, "logout!", cSession_logout_bang, 0);
  rb_define_method(cSession, "handler", cSession_handler, 0);
}