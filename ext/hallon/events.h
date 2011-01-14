#ifndef GLOBALS_H_SXKDXKPS
#define GLOBALS_H_SXKDXKPS

#include "semaphore.h"

typedef struct {
  hn_sem_t* sem_empty;
  hn_sem_t* sem_full;
  
  /* actual event data */
  VALUE rb_handler;
  VALUE (*c_handler)(void*);
  void * c_data;
} hn_event_t;

#define EVENT_SYNCHRONIZE(event, code) do {\
  hn_sem_wait((event)->sem_empty);\
  code;\
  hn_sem_post((event)->sem_full);\
} while(0)

#define EVENT_CREATE(event, recv, fn, args) do {\
  EVENT_SYNCHRONIZE(event, {\
    (event)->rb_handler = (recv);\
    (event)->c_handler  = (fn);\
    (event)->c_data     = (args);\
  });\
} while(0)

#endif /* end of include guard: GLOBALS_H_SXKDXKPS */
