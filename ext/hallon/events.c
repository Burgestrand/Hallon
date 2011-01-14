#include "common.h"
#include "events.h"

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

/*
  Non-GVL versions of semaphore wait/post.
*/
static VALUE hn_sem_wait_nogvl(void *hn_sem) { return (VALUE) hn_sem_wait(hn_sem); }
static VALUE hn_sem_post_nogvl(void *hn_sem) { return (VALUE) hn_sem_post(hn_sem); }

/*
  Prototypes
*/
static VALUE taskmaster_thread(void *);
static void hn_ubf_sem_full(void *);

/*
  Spawn the Taskmaster thread, delivering tasks to the given Queue.
  
  @param [Queue] queue
  @return [Thread]
*/
static VALUE cEvents_s_spawn_taskmaster(VALUE mEvents, VALUE queue)
{
  return rb_thread_create(taskmaster_thread, (void*) queue);
}

static VALUE taskmaster_thread(void *q)
{
  VALUE queue = (VALUE) q;
  ID id_push  = rb_intern("push");
  
  for (;;)
  {
    rb_thread_blocking_region(hn_sem_wait_nogvl, g_event->sem_full, hn_ubf_sem_full, NULL);
    if (NIL_P(g_event->receiver)) continue; // we were woken up
    assert(g_event->handler);
    rb_funcall(queue, id_push, 1, rb_ary_unshift(g_event->handler(g_event->data), g_event->receiver));
    hn_proc_without_gvl(hn_sem_post_nogvl, g_event->sem_empty);
  }
  
  return queue;
}

static void hn_ubf_sem_full(void *x) // post a NIL-event to wake up taskmaster
{
  EVENT_CREATE(g_event, Qnil, NULL, NULL);
}

void Init_Events(void)
{
  VALUE mEvents = rb_define_module_under(hn_mHallon, "Events");
  rb_define_singleton_method(mEvents, "spawn_taskmaster", cEvents_s_spawn_taskmaster, 1);
}