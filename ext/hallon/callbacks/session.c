/*
  This file defines session callbacks.
  
  @note This file is included by callbacks.h; only reason I’ve separated
        them is for organizational purpose.
  @see http://developer.spotify.com/en/libspotify/docs/structsp__session__callbacks.html
*/
#define DATA_HANDLER(ptr) (((hn_spotify_data_t*) sp_session_userdata(session_ptr))->handler)


/*
  no data-callbacks
*/
static VALUE ruby_notify_main_thread(void *x)
{
  return EVENT_ARRAY("notify_main_thread", 0);
}
static void c_notify_main_thread(sp_session *session_ptr)
{
  EVENT_CREATE(DATA_HANDLER(session_ptr), ruby_notify_main_thread, NULL);
}


static VALUE ruby_logged_out(void *x)
{
  return EVENT_ARRAY("logged_out", 0);
}
static void c_logged_out(sp_session *session_ptr)
{
  EVENT_CREATE(DATA_HANDLER(session_ptr), ruby_logged_out, NULL);
}


static VALUE ruby_metadata_updated(void *x)
{
  return EVENT_ARRAY("metadata_updated", 0);
}
static void c_metadata_updated(sp_session *session_ptr)
{
  EVENT_CREATE(DATA_HANDLER(session_ptr), ruby_metadata_updated, NULL);
}


static VALUE ruby_play_token_lost(void *x)
{
  return EVENT_ARRAY("play_token_lost", 0);
}
static void c_play_token_lost(sp_session *session_ptr)
{
  EVENT_CREATE(DATA_HANDLER(session_ptr), ruby_play_token_lost, NULL);
}



/*
  primitive data-callbacks (nothing but typecasts)
*/
static VALUE ruby_logged_in(void *error)
{
  return EVENT_ARRAY("logged_in", 1, INT2FIX((sp_error) error));
}
static void c_logged_in(sp_session *session_ptr, sp_error error)
{
  EVENT_CREATE(DATA_HANDLER(session_ptr), ruby_logged_in, (void*) error);
}


static VALUE ruby_connection_error(void *error)
{
  return EVENT_ARRAY("connection_error", 1, INT2FIX((sp_error) error));
}
static void c_connection_error(sp_session *session_ptr, sp_error error)
{
  EVENT_CREATE(DATA_HANDLER(session_ptr), ruby_connection_error, (void*) error);
}



/*
  complex data-callbacks (mallocation)
*/
static VALUE ruby_log_message(void *x)
{
  VALUE message = rb_str_new2((char*) x);
  xfree(x); /* free malloc’d message string */
  return EVENT_ARRAY("log_message", 1, message);
}
static void c_log_message(sp_session *session_ptr, const char *message)
{
  char *data = ALLOC_N(char, strlen(message) + 1);
  EVENT_CREATE(DATA_HANDLER(session_ptr), ruby_log_message, (void*) strcpy(data, message));
}


static VALUE ruby_message_to_user(void *x)
{
  VALUE message = rb_str_new2((char*) x);
  xfree(x); /* free malloc’d message string */
  return EVENT_ARRAY("message_to_user", 1, message);
}
static void c_message_to_user(sp_session *session_ptr, const char *message)
{
  char *data = ALLOC_N(char, strlen(message) + 1);
  EVENT_CREATE(DATA_HANDLER(session_ptr), ruby_message_to_user, (void*) strcpy(data, message));
}


const sp_session_callbacks HALLON_SESSION_CALLBACKS = 
{
 .logged_in              = c_logged_in,
 .logged_out             = c_logged_out,
 .metadata_updated       = c_metadata_updated,
 .connection_error       = c_connection_error,
 .message_to_user        = c_message_to_user,
 .play_token_lost        = c_play_token_lost,
 .streaming_error        = NULL,
 .log_message            = c_log_message,
 .userinfo_updated       = NULL,
 .notify_main_thread     = c_notify_main_thread,
 .music_delivery         = NULL,
 .end_of_track           = NULL,
 .start_playback         = NULL,
 .stop_playback          = NULL,
 .get_audio_buffer_stats = NULL
};