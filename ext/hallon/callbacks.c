#include "common.h"
#include "callbacks.h"

/*
  Considering not all libspotify method calls require a reference to the current
  session (meaning we cannot retrieve its’ event semaphores), we need a way to
  reach the event semaphore without it. The only way I know how to do that is
  using a global variable.
  
  At the moment, libspotify is not multi-session friendly. This means a global
  variable will not affect future development until libspotify can handle more
  than one session.
*/
hn_event_t * g_event;

#define EVENT_CREATE(rb_h, c_h, data) do {\
  hn_sem_wait(g_event->sem_empty);\
  g_event->rb_handler = (rb_h);\
  g_event->c_handler  = (c_h);\
  g_event->c_data     = (data);\
  hn_sem_post(g_event->sem_full);\
} while(0)

/* Non-GVL of sem_wait/post */
static VALUE hn_sem_wait_nogvl(void *hn_sem) { return (VALUE) hn_sem_wait(hn_sem); }
static VALUE hn_sem_post_nogvl(void *hn_sem) { return (VALUE) hn_sem_post(hn_sem); }

/* wake up taskmaster thread when its’ sleeping */
static void  hn_ubf_sem_full(void *x) { EVENT_CREATE(Qnil, NULL, NULL); }

/* see Session#spawn_taskmaster */
VALUE taskmaster_thread(void *q)
{
  VALUE queue = (VALUE) q;
  ID id_push  = rb_intern("push");
  
  for (;;)
  {
    rb_thread_blocking_region(hn_sem_wait_nogvl, g_event->sem_full, hn_ubf_sem_full, NULL);
    
    // if we were woken up by ubf-function, handler will be nil
    if ( ! NIL_P(g_event->rb_handler))
    {
      rb_funcall(queue, id_push, 1,
        rb_ary_unshift(g_event->c_handler(g_event->c_data), g_event->rb_handler));
    }
    
    g_event->rb_handler = Qnil;
    hn_proc_without_gvl(hn_sem_post_nogvl, g_event->sem_empty);
  }
  
  return queue;
}

/*
  -------------------------------------------------------------------
  
  Used to be for debugging purposes only, but now it is used to fire
  arbitrary events. It takes a ruby array as an argument;
  
  [0]: receiver, object to handle the callback
  [1]: array of:
    [0]: method to call (symbol)
    [1…]: arguments
*/
static VALUE ruby_session_fire(void *argv) { return (VALUE) argv; }
VALUE hn_session_fire(void *ary)
{
  VALUE *argv = (VALUE*) ary;
  EVENT_CREATE(argv[0], ruby_session_fire, (void*) argv[1]);
  return Qtrue;
}

/*
  Callback-definitions.
  
  Each of these files define pairs of ruby- and C handlers, and in the
  very end they define a structure that contains pointers to each C
  handler.
  
  The C handler is what gets called by libspotify, and will populate the
  g_event data structure with information about the event. It will also
  define which ruby handler to use to unmarshal the data.
  
  The ruby handler has a tricky name; it is a C function that returns
  a ruby array containing the data that the C handler was invoked with.
  It does this by pulling data out of the pointer in the g_event struct.
*/
#define EVENT_ARRAY(name, argc, ...) (rb_ary_new3((argc) + 1, STR2SYM((name)) , ##__VA_ARGS__))
#include "callbacks/session.c"