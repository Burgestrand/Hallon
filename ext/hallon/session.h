#ifndef __SESSION__
  #define __SESSION__
  
  #include "session_events.h"
  
  typedef struct
  {
    /* session pointer */
    sp_session** session_ptr;
  
    /* event mutex and condition signal */
    pthread_mutex_t event_mutex;
    pthread_cond_t  event_signal;
    callback_event_t* event;
  } session_data_t;

  static VALUE cSession_alloc(VALUE);
  static void cSession_free(session_data_t*);

  static VALUE cSession_state(VALUE);
  static VALUE cSession_process_events(VALUE);

  /*
    Retrieve the data pointer from the object.
  
    @example
      DATA_OF(self)->access_mutex
  */
  #define DATA_OF(obj) Data_Fetch_Struct(obj, session_data_t)
#endif