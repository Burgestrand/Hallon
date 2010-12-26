#include "common.h"
#include "events.h" /* hn_event_t */
#include "callbacks.h"
#include "session.h" /* hn_session_data_t */

#define SESSION_EVENT_CREATE(_session_ptr, _handler, _data) do {\
  hn_session_data_t *_session_data = (hn_session_data_t*) sp_session_userdata(_session_ptr);\
  EVENT_CREATE(_session_data->event, _handler, _data, &_session_data->event_cond, &_session_data->event_mutex);\
} while(0)

/*
  Session callbacks
  -----------------
*/

static VALUE ruby_notify_main_thread(void *args)
{ return rb_ary_new3(1, STR2SYM("process_events")); }
static void callback_process_events(sp_session *session_ptr)
{ DEBUG("!! notify"); SESSION_EVENT_CREATE(session_ptr, ruby_notify_main_thread, NULL); }

static VALUE ruby_logged_in(void *args)
{ return rb_ary_new3(2, STR2SYM("logged_in"), INT2FIX((sp_error)args)); }
static void callback_logged_in(sp_session *session_ptr, sp_error error)
{ DEBUG("!! logged_in"); SESSION_EVENT_CREATE(session_ptr, ruby_logged_in, (void*) error); }

// @see session.c
const sp_session_callbacks HALLON_SESSION_CALLBACKS = 
{
 .logged_in              = callback_logged_in,
 .logged_out             = NULL,
 .metadata_updated       = NULL,
 .connection_error       = NULL,
 .message_to_user        = NULL,
 .play_token_lost        = NULL,
 .streaming_error        = NULL,
 .log_message            = NULL,
 .userinfo_updated       = NULL,
 .notify_main_thread     = callback_process_events,
 .music_delivery         = NULL,
 .end_of_track           = NULL,
 .start_playback         = NULL,
 .stop_playback          = NULL,
 .get_audio_buffer_stats = NULL
};