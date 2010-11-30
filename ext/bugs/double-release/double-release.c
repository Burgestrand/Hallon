#include <libspotify/api.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

extern uint8_t g_appkey;
extern size_t g_appkey_size;

void create_and_release(void)
{
  sp_session_callbacks callbacks = {};
  sp_session_config config = {
    .api_version          = SPOTIFY_API_VERSION,
    .cache_location       = "tmp",
    .settings_location    = "tmp",
    .application_key      = &g_appkey,
    .application_key_size = g_appkey_size,
    .user_agent           = "Hallon",
    .callbacks            = &callbacks,
    .userdata             = NULL,
    .tiny_settings        = 1,
  };
  
  sp_session *session_ptr = NULL;
  sp_error error = sp_session_create(&config, &session_ptr);
  
  fprintf(stderr, "created!\n");
  if (error != SP_ERROR_OK) fprintf(stderr, "%s", sp_error_message(error));
  sp_session_release(session_ptr);
  fprintf(stderr, "released!\n");
}

int main(void)
{
  fprintf(stderr, "creating first\n");
  create_and_release();
  fprintf(stderr, "creating second\n");
  create_and_release(); // SEGFAULT on before created!
  fprintf(stderr, "done!\n");
}