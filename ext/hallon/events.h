#ifndef GLOBALS_H_SXKDXKPS
#define GLOBALS_H_SXKDXKPS

#include "semaphore.h"

typedef struct {
  hn_sem_t* sem_empty;
  hn_sem_t* sem_full;
  
  /* actual event data */
  VALUE receiver;
  VALUE (*handler)(void*);
  void * data;
} hn_event_t;

#define EVENT_SYNCHRONIZE(event, code) do {\
  hn_sem_wait((event)->sem_empty);\
  code;\
  hn_sem_post((event)->sem_full);\
} while(0)

#define EVENT_CREATE(event, recv, fn, args) do {\
  EVENT_SYNCHRONIZE(event, {\
    (event)->receiver = (recv);\
    (event)->handler  = (fn);\
    (event)->data     = (args);\
  });\
} while(0)

#endif /* end of include guard: GLOBALS_H_SXKDXKPS */
