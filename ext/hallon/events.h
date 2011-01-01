#ifndef EVENTS_H_QF5CFKX
#define EVENTS_H_QF5CFKX

/*
  The Problem is Communication
  ============================
  libspotify uses asynchronous callbacks for event handling. Methods such as
  `sp_session_create` allows you to register which C method to use as a callback
  for each event.

  Most of the time, these callbacks are called within a separate thread created
  by libspotify. Since the callback-thread is created by libspotify, no
  callbacks can be assumed to ever hold the ruby GVL (you must hold the GVL to
  safely call ruby C api [rb_*] functions). However, in some cases callbacks
  will be executed by the same thread as the one calling Spotify functions. You
  must assume that every sp_* call might end up calling a callback as well!

  Since the callback functions cannot be assumed to hold the GVL, you must
  signal events to a thread that has the GVL and from there dispatch to the
  event handler. How this is to be done has been a major issue for me.

  The solution
  ------------
  I wrap the Spotify API by attaching C structures to the Hallon objects. This
  allows each object to keep track of which pointers to use for method calls.
  Along with that information, I also store three additional things: a mutex, a
  condition variable and an event structure. The libspotify API allows me to
  bind a pointer to this information which can then be retrieved from within the
  callbacks. As threads share memory, I can modify this structure from within
  the callbacks and all other threads will see the modification. This means I
  have a way of communicating from callback functions to ruby threads.

  However, issues arise with this as with any other concurrent program. I must
  synchronize read and write access properly. This is done using semaphores.
  
  ### Event Producer thread
  The event producer is given the Session object and a Queue. It will wait for
  events coming from libspotify, and on arrival convert them to ruby-data. This
  is then put on the Queue, ready for the event consumer to pop.
  
  ### Event Consumer thread
  It runs a tight loop, popping data off the Queue. Each event is then sent to
  the event handler (given in Session#initialize), which then handles the event.
*/

VALUE event_producer(void *);

typedef struct {
  VALUE (*handler)(void*);
  void* data;
} hn_event_t;

#define EVENT_CREATE(full, empty, event, ruby_handler, c_data) do {\
  hn_sem_wait(empty);\
  (event)->handler = (ruby_handler);\
  (event)->data    = (c_data);\
  hn_sem_post(full);\
} while(0)

#endif /* end of include guard: EVENTS_H_QF5CFKX */