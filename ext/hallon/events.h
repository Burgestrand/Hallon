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
  synchronize read and write access properly. This is done using the mutex and
  condition variable. The final structure I end up with is:

  ### Ruby Main thread
  This is the thread your application mainly runs in. It has the GVL and can
  call ruby functions. Nothing special about this, every ruby thread has this.

  ### Event Producer thread
  This thread is started in Session#initialize. It is given the C structure
  containing the event mutex, event condition variable and event structure.
  The first thing it does is raising its’ own priority (to run as often as 
  possible) and then it locks the event mutex.
  
  Once the mutex is locked it will go into an infinite loop, waiting to be
  signaled of an event. When the event arrives it will use the event to
  construct a ruby structure containing event data.
  
  As a final task it will put this event data into a ruby Queue, which is
  being read by the Event Consumer thread. The reason for this extra consumer
  thread is that acting upon an event might invoke a callback. Callbacks take
  the event mutex to mark the event, which is already held by the producer.
  Locking the same lock twice results in a deadlock!
  
  ### Event Consumer thread
  This consumer constantly pops events off of the Event Queue; a queue which
  is shared between the producer and the consumer to allow acting upon
  callbacks.
*/

VALUE event_producer(void *);

typedef struct {
  VALUE (*handler)(void*);
  void* data;
} hn_event_t;

#define EVENT_CREATE(_event, _handler, _data, cond, mutex) do {\
  pthread_mutex_lock(mutex);\
  (_event)->handler = (_handler);\
  (_event)->data    = (_data);\
  pthread_cond_signal(cond);\
  /*usleep(10);*/\
  pthread_mutex_unlock(mutex);\
} while(0)

#endif /* end of include guard: EVENTS_H_QF5CFKX */