#ifndef BASE_H_P59M8SXY
#define BASE_H_P59M8SXY

typedef void (*sp_free_func)(void*);
typedef struct
{
  VALUE  handler;
  void (**spotify_ptr);
  sp_free_func free_func;
} hn_spotify_data_t;

#endif BASE_H_P59M8SXY */