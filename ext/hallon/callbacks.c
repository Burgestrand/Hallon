#include "common.h"
#include "events.h" /* hn_event_t */
#include "callbacks.h"

/* GLOBAL: events.c */
extern hn_event_t * g_event;

/*
  Used to be for debugging purposes only, but now it is used to fire arbitrary
  events at the event_producer.
*/
static VALUE ruby_session_fire(void *argv) { return (VALUE) argv; }
VALUE hn_session_fire(void *ary)
{
  VALUE *argv = (VALUE*) ary;
  EVENT_CREATE(g_event, argv[0], ruby_session_fire, (void*) argv[1]);
  return Qtrue;
}

/*
  Session callbacks
  
  @see http://developer.spotify.com/en/libspotify/docs/structsp__session__callbacks.html
*/
static VALUE ruby_process_events(void *x) { return rb_ary_new3(1, STR2SYM("process_events")); }
static void c_process_events(sp_session *session_ptr)
{
  hn_spotify_data_t *data = (hn_spotify_data_t*) sp_session_userdata(session_ptr);
  EVENT_CREATE(g_event, data->handler, ruby_process_events, NULL);
}

/* The simple callbacks, with nothing but names and no arguments. */


/* Even trickier: string argument! (does stack get popped? do we need to copy the string?) */


/* @see session.c */
const sp_session_callbacks HALLON_SESSION_CALLBACKS = 
{
 .logged_in              = NULL,
 .logged_out             = NULL,
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