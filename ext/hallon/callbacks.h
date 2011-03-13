#ifndef CALLBACKS_H_HPVSGQG0
  #define CALLBACKS_H_HPVSGQG0

  #include "semaphore.h"
  
  typedef struct {
    hn_sem_t* sem_empty;
    hn_sem_t* sem_full;
  
    /* actual event data */
    VALUE rb_handler;
    VALUE (*c_handler)(void*);
    void * c_data;
  } hn_event_t;

  /* Firing arbitrary events from ruby */
  VALUE hn_as_callback_fire(void *);
  VALUE taskmaster_thread(void *);

  /* Each of these are defined in callbacks/<spotify object>.c */
  extern const sp_session_callbacks HALLON_SESSION_CALLBACKS;
#endif