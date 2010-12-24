/*
  Retrieve the data pointer from the object.
  
  @example
    DATA_OF(self)->access_mutex
*/
#define DATA_OF(obj) Data_Fetch_Struct(obj, session_data_t)

/*
  An easy way to share data between Spotify threads and Ruby threads.
*/
typedef struct
{
  /* session pointer */
  sp_session** session_ptr;
  
  /* mutex for accessing this struct */
  pthread_mutex_t access_mutex;
  
  /* callbacks */
  pthread_cond_t cb_notify_cond;
} session_data_t;

static VALUE cSession_alloc(VALUE);
static void cSession_free(session_data_t*);

static VALUE cSession_state(VALUE);
static VALUE cSession_process_events(VALUE);