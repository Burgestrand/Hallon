/*
  This file defines session callbacks.
  
  @note This file is included by callbacks.h; only reason I’ve separated
        them is for organizational purpose.
  @see http://developer.spotify.com/en/libspotify/docs/structsp__session__callbacks.html
*/
#define DATA_HANDLER(ptr) (((hn_spotify_data_t*) sp_session_userdata(session_ptr))->handler)

static VALUE ruby_process_events(void *x)
{
  return EVENT_ARRAY("process_events", 0);
}
static void c_process_events(sp_session *session_ptr)
{
  EVENT_CREATE(DATA_HANDLER(session_ptr), ruby_process_events, NULL);
}

static VALUE ruby_logged_in(void *error)
{
  return EVENT_ARRAY("logged_in", 1, INT2FIX((sp_error) error));
}
static void c_logged_in(sp_session *session_ptr, sp_error error)
{
  EVENT_CREATE(DATA_HANDLER(session_ptr), ruby_logged_in, (void*) error);
}

static VALUE ruby_logged_out(void *x)
{
  return EVENT_ARRAY("logged_out", 0);
}
static void c_logged_out(sp_session *session_ptr)
{
  EVENT_CREATE(DATA_HANDLER(session_ptr), ruby_logged_out, NULL);
}

const sp_session_callbacks HALLON_SESSION_CALLBACKS = 
{
 .logged_in              = c_logged_in,
 .logged_out             = c_logged_out,
 .metadata_updated       = NULL,
 .connection_error       = NULL,
 .message_to_user        = NULL,
 .play_token_lost        = NULL,
 .streaming_error        = NULL,
 .log_message            = NULL,
 .userinfo_updated       = NULL,
 .notify_main_thread     = c_process_events,
 .music_delivery         = NULL,
 .end_of_track           = NULL,
 .start_playback         = NULL,
 .stop_playback          = NULL,
 .get_audio_buffer_stats = NULL
};