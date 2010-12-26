#include "common.h"
#include "events.h"
#include "session.h"

VALUE event_consumer(void *argv)
{
  ID send = rb_intern("send");
  VALUE session, queue;
  rb_scan_args(2, argv, "20", &session, &queue);
  
  for(;;)
  {
    DEBUG("Consumer: waiting…");
    VALUE event = rb_funcall3(queue, rb_intern("shift"), 0, NULL);
    VALUE s_event = rb_inspect(event);
    DEBUG(StringValueCStr(s_event));
    rb_apply(session, send, event);
  }
}

VALUE event_producer(void *argv)
{
  VALUE session, queue;
  rb_scan_args(2, argv, "20", &session, &queue);
  hn_session_data_t *session_data = DATA_OF(session);
  
  // TODO: make this thread critical (high priority)
  DEBUG("Producer: Lock mutex");
  pthread_mutex_lock_nogvl(&session_data->event_mutex);
  DEBUG("Producer: Got lock!");
  for(;;)
  {
    pthread_cond_signal_nogvl(&session_data->startup_cond);
    DEBUG("Producer: waiting…");
    session_data->event->handler = NULL;
    pthread_cond_wait_nogvl(&session_data->event_cond, &session_data->event_mutex);
    assert(session_data->event->handler);
    DEBUG("Producer: handling…");
    VALUE ruby_event = session_data->event->handler(session_data->event->data);
    rb_funcall3(queue, rb_intern("push"), 1, &ruby_event);
  }
  // TODO: rb_ensure(mutex_unlock)
  pthread_mutex_unlock(&session_data->event_mutex);
}