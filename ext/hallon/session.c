#include "common.h"
#include "callbacks.h" /* hn_session_fire */

/*
  Useful macros :D
*/
#define SESSPTR_OF(obj) *((sp_session**) DATA_OF(obj)->spotify_ptr)
#define DATA_OF(obj) Data_Fetch_Struct(obj, hn_spotify_data_t)

/*
  Prototypes
*/
static VALUE sp_session_process_events_nogvl(void *);
static VALUE sp_session_login_nogvl(void *);
static VALUE sp_session_logout_nogvl(void *);

/*
  @overload initialize(appkey, options = {}, &block)

    Creates a new Spotify session with the given parameters using `sp_session_create`.
  
    @example
       session = Hallon::Session.instance(appkey, :settings_path => "tmp") do
         on(:logged_in) do |error|
           puts "We logged in successfully. Lets bail!"
           exit
         end
       end
  
    @note Until `libspotify` allows you to create more than one session, you must
          use {Hallon::Session.instance} instead of this method.
  
    @param [#to_s] appkey your `libspotify` application key.
    @param [Hash] options additional options
    @option options [String] :user_agent ("Hallon") User-Agent to use (length < 256)
    @option options [String] :settings_path ("tmp") where to save settings and user-specific cache
    @option options [String] :cache_path ("") where to save cache files (set to "" to disable)
    @option options [Bool]   :load_playlists (true) load playlists into RAM on startup
    @option options [Bool]   :compress_playlists (true) compress local copies of playlists
    @option options [Bool]   :cache_playlist_metadata (true) cache metadata for playlists locally
    @yield allows you to define handlers for events (see {Base#on})
    @raise [ArgumentError] if options[:user_agent] is more than 255 characters long
    @raise [Hallon::Error] if `sp_session_create` fails
    @see http://developer.spotify.com/en/libspotify/docs/structsp__session__config.html
*/
static VALUE cSession_initialize(int argc, VALUE *argv, VALUE self)
{
  VALUE appkey, options;
  hn_spotify_data_t *session_data = DATA_OF(self);
  rb_call_super(0, NULL); // IMPORTANT, see Hallon::Base
  
  /* handle options */
  rb_scan_args(argc, argv, "12", &appkey, &options);
  options = rb_funcall(self, rb_intern("merge_defaults"), 1, options);
  VALUE user_agent    = hn_hash_lookup_sym(options, "user_agent"),
        settings_path = hn_hash_lookup_sym(options, "settings_path"),
        cache_path    = hn_hash_lookup_sym(options, "cache_path"),
        
        load_playlists = hn_hash_lookup_sym(options, "load_playlists"),
        compress_playlists = hn_hash_lookup_sym(options, "compress_playlists"),
        cache_playlist_metadata = hn_hash_lookup_sym(options, "cache_playlist_metadata");
  
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
    .compress_playlists   = RTEST(compress_playlists),
    .initially_unload_playlists = ! RTEST(load_playlists),
    .dont_save_metadata_for_playlists = ! RTEST(cache_playlist_metadata),
  };
  
  /* @note This calls the `notify_main_thread` callback once from the same pthread. */
  sp_error error = sp_session_create(&config, (sp_session**) session_data->spotify_ptr);
  hn_eError_maybe_raise(error);
  
  /* spawn the event producer & consumer */
  VALUE threads = rb_funcall2(self, rb_intern("spawn_handlers"), 0, NULL);
  
  rb_iv_set(self, "@threads", threads);
  rb_iv_set(self, "@appkey", appkey);
  rb_iv_set(self, "@options", options);
  
  return self;
}

/*
  Waits for the global event variable to contain an event. Once an event
  arrives, it is sent to the event queue and then handled by its’ handler.
  
  @note We use a separate thread for firing the event to avoid deadlock.
  
  @param [Queue] queue event queue
  @return [Thread] taskmaster thread
*/
static VALUE cSession_spawn_taskmaster(VALUE self, VALUE queue)
{
  return rb_thread_create(taskmaster_thread /* callbacks.c */, (void*) queue);
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
  @overload login(username, password)
    Logs in to Spotify using the given account name and password.
  
    @note This call returns immediately. You are not logged in until
          the `logged_in` event has been fired on this Session.
    @param [#to_s] username
    @param [#to_s] password
    @return [Session]
*/
static VALUE cSession_login(VALUE self, VALUE username, VALUE password)
{
  void *argv[] = { SESSPTR_OF(self), StringValueCStr(username), StringValueCStr(password) };
  hn_proc_without_gvl(sp_session_login_nogvl, argv);
  return self;
}

/* just paranoia, actually */
static VALUE sp_session_login_nogvl(void *_argv)
{
  void **argv = (void**) _argv;
  sp_session_login((sp_session*) argv[0], (char*) argv[1], (char*) argv[2]);
  return Qnil;
}

/*
  @overload fire!(receiver, method, *arguments)
    Fires an event, as if it was generated by `libspotify`.
  
    What this does is that it puts an event in the event queue; ready to
    be picked up by the event dispatcher. Calling this method is pretty
    much the same thing as doing the following:
    `receiver.send(:"on_#{method}", *arguments)`
        
    The only difference is that the method called by the same thread
    that dispatches events from libspotify.
  
    @param [Object] receiver
    @param [#to_s] method
    @param [Object, …] arguments
    @return [Session]
*/
static VALUE cSession_fire_bang(int argc, VALUE *argv, VALUE self)
{
  VALUE recv, method, brgs;
  rb_scan_args(argc, argv, "2*", &recv, &method, &brgs);
  void *args[] = { (void*) recv, (void*) rb_ary_unshift(brgs, method) };
  hn_proc_without_gvl(hn_as_callback_fire, args);
  return self;
}

/*
  Logs out of Spotify. Does nothing if not logged in.
  
  @note This call returns immediately. You are not logged out until
        the `logged_out` event has been fired on this session.
  @return [Session]
*/
static VALUE cSession_logout(VALUE self)
{
  if (rb_funcall3(self, rb_intern("logged_in?"), 0, NULL) == Qtrue)
  {
    hn_proc_without_gvl(sp_session_logout_nogvl, SESSPTR_OF(self));
  }
  
  return self;
}

static VALUE sp_session_logout_nogvl(void *session_ptr)
{
  sp_session_logout(session_ptr);
  return Qnil;
}

/*
  The Session is fundamental for all communication with Spotify. Pretty much *all*
  API calls require you to have established a session with Spotify before
  using them.
  
  @see https://developer.spotify.com/en/libspotify/docs/group__session.html
*/
void Init_Session(void)
{
  VALUE cSession = rb_define_class_under(hn_mHallon, "Session", hn_cBase);
  rb_define_method(cSession, "initialize", cSession_initialize, -1);
  rb_define_method(cSession, "status", cSession_status, 0);
  rb_define_method(cSession, "process_events", cSession_process_events, 0);
  rb_define_method(cSession, "login", cSession_login, 2);
  rb_define_method(cSession, "fire!", cSession_fire_bang, -1);
  rb_define_method(cSession, "logout", cSession_logout, 0);
  
  rb_define_private_method(cSession, "spawn_taskmaster", cSession_spawn_taskmaster, 1);
  
  extern hn_event_t * g_event;
  g_event = ALLOC(hn_event_t);
  g_event->sem_empty  = hn_sem_init(1);
  g_event->sem_full   = hn_sem_init(0);
  g_event->rb_handler = Qnil;
  g_event->c_handler  = NULL;
  g_event->c_data     = NULL;
}