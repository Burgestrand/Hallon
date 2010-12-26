#include "common.h"
#include "events.h"
#include "session.h"

VALUE event_producer(void *argv)
{
  ID push = rb_intern("push");
  VALUE session, queue;
  rb_scan_args(2, argv, "20", &session, &queue);
  hn_session_data_t *session_data = DATA_OF(session);
  
  pthread_mutex_lock_nogvl(&session_data->event_mutex);
  pthread_cond_signal_nogvl(&session_data->startup_cond);
  for(;;)
  {
    DEBUG("…");
    session_data->event->handler = NULL;
    pthread_cond_wait_nogvl(&session_data->event_cond, &session_data->event_mutex);
    assert(session_data->event->handler);
    VALUE ruby_event = session_data->event->handler(session_data->event->data);
    VALUE s_ruby_event = rb_inspect(ruby_event);
    DEBUG(StringValueCStr(s_ruby_event));
    rb_funcall3(queue, push, 1, &ruby_event);
  }
  // TODO: rb_ensure(mutex_unlock)
  pthread_mutex_unlock(&session_data->event_mutex);
}