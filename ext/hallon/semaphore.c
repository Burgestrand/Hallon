#include <assert.h>
#include <pthread.h>
#include "common.h"
#include "semaphore.h"

/*
  As pthread_mutex does not allow one to unlock mutexes not locked by its’ own
  thread, and unnamed POSIX semaphores does not exist on Mac OS, I made my own
  semaphore library to work around it.
*/


/*
  Blows up if the given expression is not what was expected.
  
  @note We do not print the `expression` or `expected` values, as each operation
  might have side effects and return different values next invocation (if any at
  all!).
*/
#define guard_true(expression, expected) do {\
  if ((expression) != (expected)) OMGWTF(#expression " failed");\
} while(0)

/*
  Locks the semaphore mutex and executes the given code within the mutex lock.
*/
#define synchronize(sem, code) do {\
  pthread_mutex_lock(&(sem)->mutex);\
  code;\
  pthread_mutex_unlock(&(sem)->mutex);\
} while(0)

/*
  Creates a new Semaphore with the given initial value.
  
  @param [int] capacity
  @return [hn_sem*]
*/
hn_sem_t *hn_sem_init(int init)
{
  hn_sem_t *sem = ALLOC(hn_sem_t);
  
  sem->value = init;
  guard_true(pthread_mutex_init(&sem->mutex, NULL), 0);
  guard_true(pthread_cond_init(&sem->notZero, NULL), 0);
  
  return sem;
}

/*
  Frees a previously created Semaphore. It must have the count 0 or the behavior
  is undefined.
  
  @param [hn_sem*]
  @return [void]
*/
void hn_sem_destroy(hn_sem_t* sem)
{
  assert(sem);
  guard_true(pthread_mutex_destroy(&sem->mutex), 0);
  guard_true(pthread_cond_destroy(&sem->notZero), 0);
  xfree(sem);
}

/*
  Reserves a unit on the semaphore, blocking call if the count is 0.
  
  @param [hn_sem*]
  @return [int] value after operation
*/
int hn_sem_wait(hn_sem_t* sem)
{
  int value = 0;
  synchronize(sem, {
    while(sem->value <= 0)
    {
      guard_true(pthread_cond_wait(&sem->notZero, &sem->mutex), 0);
    }
    value = --(sem->value);
  });
  return value;
}

/*
  Adds a unit to the semaphore. It is subject to integer overflow.
  
  @param [hn_sem*]
  @return [int] capacity after operation
*/
int hn_sem_post(hn_sem_t *sem)
{
  int value = 0;
  synchronize(sem, {
    if (sem->value == 0)
    {
      guard_true(pthread_cond_signal(&sem->notZero), 0);
    }
    value = ++(sem->value);
  });
  return value;
}