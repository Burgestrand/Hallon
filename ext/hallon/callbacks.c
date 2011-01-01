#include "common.h"
#include "events.h" /* hn_event_t */
#include "callbacks.h"
#include "session.h" /* hn_session_data_t */
#include "semaphore.h"

#define SESSION_EVENT_CREATE(_session_ptr, _handler, _data) do {\
  hn_session_data_t *session_data = (hn_session_data_t*) sp_session_userdata(_session_ptr);\
  EVENT_CREATE(session_data->event_full, session_data->event_empty,\
               session_data->event, _handler, _data);\
} while(0)

/*
  Most of these callbacks are just boilerplate. These macros makes it a little
  wee bit easier.
*/
#define DEFINE_NAMED_CALLBACK(name) \
  static VALUE ruby_##name(void *data) { return rb_ary_new3(1, STR2SYM(#name)); }\
  static void c_##name(sp_session *session_ptr) { SESSION_EVENT_CREATE(session_ptr, ruby_##name, NULL); }

#define DEFINE_ERROR_CALLBACK(name) \
  static VALUE ruby_##name(void *error) { return rb_ary_new3(2, STR2SYM(#name), INT2FIX((sp_error)error)); }\
  static void c_##name(sp_session *session_ptr, sp_error error) { SESSION_EVENT_CREATE(session_ptr, ruby_##name, (void*)error); }


/*
  Used to be for debugging purposes only, but now it is used to fire arbitrary
  events at the event_producer.
*/
static VALUE ruby_session_fire(void *argv)
{
  return (VALUE) argv;
}

VALUE hn_session_fire(void *_argv)
{
  void **argv = (void**) _argv;
  SESSION_EVENT_CREATE((sp_session*) argv[0], ruby_session_fire, argv[1]);
  return Qnil;
}

/*
  Session callbacks
  
  @see http://developer.spotify.com/en/libspotify/docs/structsp__session__callbacks.html
*/

/* The simple callbacks, with nothing but names and no arguments. */
DEFINE_NAMED_CALLBACK(process_events);
DEFINE_NAMED_CALLBACK(logged_out);
DEFINE_NAMED_CALLBACK(metadata_updated);
DEFINE_NAMED_CALLBACK(play_token_lost);
DEFINE_NAMED_CALLBACK(userinfo_updated);
DEFINE_NAMED_CALLBACK(end_of_track);
DEFINE_NAMED_CALLBACK(start_playback);
DEFINE_NAMED_CALLBACK(stop_playback);

/* Trickier callbacks: error argument! */
DEFINE_ERROR_CALLBACK(logged_in);
DEFINE_ERROR_CALLBACK(connection_error);
DEFINE_ERROR_CALLBACK(streaming_error);

/* Even trickier: string argument! (does stack get popped? do we need to copy the string?) */


/* @see session.c */
const sp_session_callbacks HALLON_SESSION_CALLBACKS = 
{
 .logged_in              = c_logged_in,
 .logged_out             = c_logged_out,
 .metadata_updated       = c_metadata_updated,
 .connection_error       = c_connection_error,
 .message_to_user        = NULL,
 .play_token_lost        = c_play_token_lost,
 .streaming_error        = NULL,
 .log_message            = NULL,
 .userinfo_updated       = c_userinfo_updated,
 .notify_main_thread     = c_process_events,
 .music_delivery         = NULL,
 .end_of_track           = c_end_of_track,
 .start_playback         = c_start_playback,
 .stop_playback          = c_stop_playback,
 .get_audio_buffer_stats = NULL
};