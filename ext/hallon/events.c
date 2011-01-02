#include "common.h"
#include "events.h" /* hn_event_t */
#include "session.h" /* hn_session_data_t */

/*
  Bad coding practice. Boo.
*/
static VALUE hn_sem_wait_nogvl(void *hn_sem) { return (VALUE) hn_sem_wait(hn_sem); }
static VALUE hn_sem_post_nogvl(void *hn_sem) { return (VALUE) hn_sem_post(hn_sem); }

/*
  To unblock the waiting for events, we send it an event that returns nil! D:
*/
static VALUE ruby_event_producer_quit(void *data) { return Qnil; }
static void hn_event_full_unblock(void *_session_data)
{
  hn_session_data_t *session_data = (hn_session_data_t*) _session_data;
  EVENT_CREATE(session_data->event_full, session_data->event_empty,
    session_data->event, ruby_event_producer_quit, NULL);
}

/*
  Reads events from the C callback functions. The procedure is this:
  
  Two semaphores:
    event_full:  0
    event_empty: 1
  
  event_producer:
    event_full.wait
    # do work
    event_empty.post
    
  libspotify_callback:
    event_empty.wait
    # fill work queue
    event_full.post
*/
VALUE event_producer(void *_session_data)
{
  ID push = rb_intern("push");
  hn_session_data_t *session_data = (hn_session_data_t*) _session_data;
  
  do
  {
    /*
      wait for events, when they arrive we invoke their ruby handler with the data
      
      the handler is expected to return an array, whereas the first element is a
      symbol representing the event name. if it is nil, however, it means this
      thread needs to be woken up!
      
      NOTE: if this thread is ever killed, no events will be allowed to fill
            the event structure EVER, thus all callbacks will block. if thread
            dies we need to make sure no callbacks will be called from thereon.
    */
    rb_thread_blocking_region(hn_sem_wait_nogvl, session_data->event_full, hn_event_full_unblock, session_data);
    
    // TODO: rb_protect? -> rb_f_abort
    VALUE ruby_event = session_data->event->handler(session_data->event->data);
    
    /* if it’s NIL (no data whatsoever from the callback), it means we were woken up */
    if (ruby_event == Qnil) continue;
    
    /* dispatch, we are done */
    rb_funcall3(session_data->event_queue, push, 1, &ruby_event);
    hn_proc_without_gvl(hn_sem_post_nogvl, session_data->event_empty); /* no UBF for this */
  } while(1);
  
  return Qtrue;
}