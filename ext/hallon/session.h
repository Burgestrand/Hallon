#ifndef SESSION_H_N4NAEFIZ
#define SESSION_H_N4NAEFIZ

#include "semaphore.h"

typedef struct
{
  /* ruby data */
  VALUE session_obj;
  VALUE event_queue;
  
  /* session pointer & object */
  sp_session** session_ptr;

  /* event mutex and condition signal */
  hn_sem_t* event_empty;
  hn_sem_t* event_full;
  hn_event_t* event;
} hn_session_data_t;

/*
  Macros
*/
#define DATA_OF(obj) Data_Fetch_Struct(obj, hn_session_data_t)

#endif /* end of include guard: SESSION_H_N4NAEFIZ */