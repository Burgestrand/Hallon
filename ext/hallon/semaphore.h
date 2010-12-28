#ifndef SEMAPHORE_C_V0CBS00W
#define SEMAPHORE_C_V0CBS00W

typedef struct
{
  int value;
  pthread_mutex_t mutex;
  pthread_cond_t notZero;
} hn_sem_t;

hn_sem_t *hn_sem_init(int init);
void hn_sem_destroy(hn_sem_t*);
int hn_sem_wait(hn_sem_t*);
int hn_sem_post(hn_sem_t*);

#endif /* end of include guard: SEMAPHORE_C_V0CBS00W */
