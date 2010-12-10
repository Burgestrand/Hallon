#include <libspotify/api.h>
#include <stdlib.h>
#include <stdio.h>

extern uint8_t g_appkey;
extern size_t g_appkey_size;

int main(void)
{
  long int muppets = 1337;
  char tmpdir[] = "/tmp/single-release.libspotify.XXXXXX";
  mkdtemp(tmpdir);
  
  sp_session_callbacks callbacks = {};
  sp_session_config config = {
    .api_version          = SPOTIFY_API_VERSION,
    .cache_location       = tmpdir,
    .settings_location    = tmpdir,
    .application_key      = &g_appkey,
    .application_key_size = g_appkey_size,
    .user_agent           = "Hallon",
    .callbacks            = &callbacks,
    .userdata             = (void *) muppets,
    .tiny_settings        = 1,
  };
  
  sp_session *session_ptr = NULL;
  sp_error error = sp_session_create(&config, &session_ptr);
  
  if (error != SP_ERROR_OK)
  {
    fprintf(stderr, "error: %s", sp_error_message(error));
    abort();
  }
  
  sp_connectionstate state = sp_session_connectionstate(session_ptr);
  fprintf(stdout, "state: %d", state);
  sp_session_release(session_ptr);
}