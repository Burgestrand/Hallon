#include "common.h"
#include "events.h"
#include "session.h"

VALUE event_producer(void *argv)
{
  ID push = rb_intern("push");
  VALUE session, queue;
  rb_scan_args(2, argv, "20", &session, &queue);
  hn_session_data_t *session_data = DATA_OF(session);
  
  // lock event mutex
  pthread_mutex_lock_nogvl(&session_data->event_mutex);
  
  // allow session.c to continue by signaling the startup condition
  pthread_mutex_lock_nogvl(&session_data->startup_mutex);
  DEBUG("startup lock");
  pthread_cond_signal(&session_data->startup_cond);
  DEBUG("startup signal!");
  pthread_mutex_unlock(&session_data->startup_mutex);
  
  for(;;)
  {
    // wait on the condition in a loop to guard against spurious wakeups
    for(
      session_data->event->handler = NULL; /* init */
      session_data->event->handler == NULL; /* while */
      pthread_cond_wait_nogvl(&session_data->event_cond, &session_data->event_mutex) /* wait */
    ) { DEBUG("…"); }
    
    // invoke the handler with the event data to build a ruby array representing the event
    VALUE ruby_event = session_data->event->handler(session_data->event->data);
    VALUE s_ruby_event = rb_inspect(ruby_event);
    DEBUG(StringValueCStr(s_ruby_event));
    rb_funcall3(queue, push, 1, &ruby_event);
  }
  
  // TODO: rb_ensure(mutex_unlock)
  pthread_mutex_unlock(&session_data->event_mutex);
}