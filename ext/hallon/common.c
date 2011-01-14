#include "common.h"

/*
  Allocates a hn_spotify_data_t pointer.
  
  @return [hn_spotify_data_t*]
*/
hn_spotify_data_t * hn_alloc_spotify_data_t(void)
{
  hn_spotify_data_t *data_ptr = ALLOC(hn_spotify_data_t);
  data_ptr->spotify_ptr = ALLOC(void*);
  data_ptr->handler     = Qnil; /* unnecessary but explicit */
  return data_ptr;
}

/*
  Marks the given handler in the Spotify data object.
  
  @param [hn_spotify_data_t*] data
*/
void hn_mark_spotify_data_t(hn_spotify_data_t *data)
{
  rb_gc_mark(data->handler);
}