#include "common.h"
#include "events.h" /* hn_event_t */
#include "session.h" /* hn_session_data_t */

/*
  Bad coding practice. Boo.
*/
static VALUE hn_sem_wait_nogvl(void *hn_sem) { return (VALUE) hn_sem_wait(hn_sem); }
static VALUE hn_sem_post_nogvl(void *hn_sem) { return (VALUE) hn_sem_post(hn_sem); }

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
VALUE event_producer(void *argv)
{
  ID push = rb_intern("push");
  VALUE session, queue;
  rb_scan_args(2, argv, "20", &session, &queue);
  hn_session_data_t *session_data = DATA_OF(session);
  
  do
  {
    /*
      wait for events, when they arrive we invoke their ruby handler with the data
      
      the handler is expected to return an array, whereas the first element is a
      symbol representing the event name. if it is nil, however, it means this
      thread should die!
    */
    hn_proc_without_gvl(hn_sem_wait_nogvl, session_data->event_full);
    
    // TODO: rb_protect? -> rb_f_abort
    VALUE ruby_event = rb_protect(session_data->event->handler, session_data->event->data);
    
    /* if it’s NIL (no data whatsoever from the callback), it means we quit */
    if (ruby_event == Qnil) break;
    
    /* dispatch, we are done */
    rb_funcall3(queue, push, 1, &ruby_event);
    hn_proc_without_gvl(hn_sem_post_nogvl, session_data->event_empty);
  } while(1);
  
  return Qtrue;
}