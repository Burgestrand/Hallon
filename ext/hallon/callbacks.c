#include "common.h"
#include "callbacks.h"

/*
  Considering not all libspotify method calls require a reference to the current
  session (meaning we cannot retrieve its’ event semaphores), we need a way to
  reach the event semaphore without it. The only way I know how to do that is
  using a global variable.
  
  At the moment, libspotify is not multi-session friendly. This means a global
  variable will not affect future development until libspotify can handle more
  than one session.
*/
hn_event_t * g_event;

#define EVENT_CREATE(rb_h, c_h, data) do {\
  hn_sem_wait(g_event->sem_empty);\
  g_event->rb_handler = (rb_h);\
  g_event->c_handler  = (c_h);\
  g_event->c_data     = (data);\
  hn_sem_post(g_event->sem_full);\
} while(0)

#define G_EVENT_CREATE(rb_h, c_h, data) EVENT_CREATE(rb_h, c_h, data)

/* Non-GVL of sem_wait/post */
static VALUE hn_sem_wait_nogvl(void *hn_sem) { return (VALUE) hn_sem_wait(hn_sem); }
static VALUE hn_sem_post_nogvl(void *hn_sem) { return (VALUE) hn_sem_post(hn_sem); }

/* wake up taskmaster thread when its’ sleeping */
static void  hn_ubf_sem_full(void *x) { EVENT_CREATE(Qnil, NULL, NULL); }

/* see Session#spawn_taskmaster */
VALUE taskmaster_thread(void *q)
{
  VALUE queue = (VALUE) q;
  ID id_push  = rb_intern("push");
  
  for (;;)
  {
    rb_thread_blocking_region(hn_sem_wait_nogvl, g_event->sem_full, hn_ubf_sem_full, NULL);
    
    // if we were woken up by ubf-function, handler will be nil
    if ( ! NIL_P(g_event->rb_handler))
    {
      rb_funcall(queue, id_push, 1,
        rb_ary_unshift(g_event->c_handler(g_event->c_data), g_event->rb_handler));
    }
    
    g_event->rb_handler = Qnil;
    hn_proc_without_gvl(hn_sem_post_nogvl, g_event->sem_empty);
  }
  
  return queue;
}

/*
  -------------------------------------------------------------------
  
  Used to be for debugging purposes only, but now it is used to fire
  arbitrary events. It takes a ruby array as an argument;
  
  [0]: receiver, object to handle the callback
  [1]: array of:
    [0]: method to call (symbol)
    [1…]: arguments
*/
static VALUE ruby_session_fire(void *argv) { return (VALUE) argv; }
VALUE hn_session_fire(void *ary)
{
  VALUE *argv = (VALUE*) ary;
  EVENT_CREATE(argv[0], ruby_session_fire, (void*) argv[1]);
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
  G_EVENT_CREATE(data->handler, ruby_process_events, NULL);
}

static VALUE ruby_logged_in(void *error)
{
  return rb_ary_new3(2, STR2SYM("logged_in"), INT2FIX((sp_error) error));
}
static void c_logged_in(sp_session *session_ptr, sp_error error)
{
  hn_spotify_data_t *data = (hn_spotify_data_t*) sp_session_userdata(session_ptr);
  G_EVENT_CREATE(data->handler, ruby_logged_in, (void*) error);
}

static VALUE ruby_logged_out(void *x)
{
  return rb_ary_new3(1, STR2SYM("logged_out"));
}
static void c_logged_out(sp_session *session_ptr)
{
  hn_spotify_data_t *data = (hn_spotify_data_t*) sp_session_userdata(session_ptr);
  G_EVENT_CREATE(data->handler, ruby_logged_out, NULL);
}

/* The simple callbacks, with nothing but names and no arguments. */


/* Even trickier: string argument! (does stack get popped? do we need to copy the string?) */


/* @see session.c */
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