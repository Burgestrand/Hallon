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
    hn_proc_without_gvl(hn_sem_wait_nogvl, session_data->event_full);
    
    /* invoke the handler with the event data to build a ruby array representing the event */
    VALUE ruby_event = session_data->event->handler(session_data->event->data);
    VALUE s_ruby_event = rb_inspect(ruby_event);
    rb_funcall3(queue, push, 1, &ruby_event);
    
    hn_proc_without_gvl(hn_sem_post_nogvl, session_data->event_empty);
  } while(1);
  
  /* TODO: unlock shit? */
}