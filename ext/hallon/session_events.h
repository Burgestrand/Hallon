#ifndef __SESSION_EVENTS__
  #define __SESSION_EVENTS__
  
  typedef struct
  {
    /* This takes the args* and makes a Ruby array of the arguments */
    VALUE (*handler)(void *args);
    void * args;
  } callback_event_t;

  VALUE session_event_handler(VALUE);
  static VALUE session_await_event(void*);

  #define EVENT_ATOMIC(session_data, expr) do {\
    pthread_mutex_lock(&session_data->event_mutex); {\
      expr;\
    }\
    pthread_cond_signal(&session_data->event_signal);\
    pthread_mutex_unlock(&session_data->event_mutex);\
  } while(0)
#endif