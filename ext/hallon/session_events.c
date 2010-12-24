#include "common.h"
#include "session.h" /* callback_event_t */
#include "session_events.h"

/*
  Loops forever, reading events from the session data structure. On an incoming
  event it will dispatch it to the session in question!
  
  @note This is the main entry point to session_events
*/
VALUE session_event_handler(VALUE session)
{
  session_data_t *session_data = DATA_OF(session);
  VALUE r_args;
  
  pthread_mutex_lock(&session_data->event_mutex);
  
  while(1)
  {
    /* await event */
    session_data->event = NULL;
    rb_thread_blocking_region(session_await_event, (void *) session_data, RUBY_UBF_PROCESS, NULL);
    assert(session_data->event);
    
    /* rebuild and dispatch */
    r_args = session_data->event->handler(session_data->event->args);
    rb_funcall(rb_mKernel, rb_intern("puts"), 1, rb_inspect(r_args));
  }
  
  // TODO: rb_ensure
  pthread_mutex_unlock(&session_data->event_mutex);
}

/*
  Await an event to be fired on the given session data. When fired, just return
  the event.
*/
static VALUE session_await_event(void *data)
{
  session_data_t *session_data = (session_data_t*) data;
  pthread_cond_wait(&session_data->event_signal, &session_data->event_mutex);
  return (VALUE) session_data->event;
}

/*
  ------------------------------------------------------------------------------
  
  Two kinds of functions (in pairs):
  
  C (callback_): receives the event in a pthread from Spotify, fills the event
                 structure and then signals the event handler.
                 
  Ruby (builder_): receives the callback_event_t structure and builds a ruby
                   array from the values to use for dispatching.
*/

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
 .notify_main_thread     = NULL,
 .music_delivery         = NULL,
 .end_of_track           = NULL,
 .start_playback         = NULL,
 .stop_playback          = NULL,
 .get_audio_buffer_stats = NULL
};