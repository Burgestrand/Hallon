/*
  This file defines session callbacks.
  
  @note This file is included by callbacks.h; only reason I’ve separated
        them is for organizational purpose.
  @see http://developer.spotify.com/en/libspotify/docs/structsp__session__callbacks.html
*/
#define DATA_HANDLER(ptr) (((hn_spotify_data_t*) sp_session_userdata(session_ptr))->handler)


/*
  Callbacks containing no data.
  
  These are simple; we just need to specify the name of the callback.
*/
#define DEFINE_NAMEONLY_HANDLERS(name) \
  static VALUE ruby_##name(void *x)\
  {\
    return EVENT_ARRAY(#name, 0);\
  }\
  static void c_##name(sp_session *session_ptr)\
  {\
    EVENT_CREATE(DATA_HANDLER(session_ptr), ruby_##name, NULL);\
  }

DEFINE_NAMEONLY_HANDLERS(notify_main_thread);
DEFINE_NAMEONLY_HANDLERS(logged_out);
DEFINE_NAMEONLY_HANDLERS(metadata_updated);
DEFINE_NAMEONLY_HANDLERS(play_token_lost);
DEFINE_NAMEONLY_HANDLERS(end_of_track);
DEFINE_NAMEONLY_HANDLERS(userinfo_updated);
DEFINE_NAMEONLY_HANDLERS(start_playback);
DEFINE_NAMEONLY_HANDLERS(stop_playback);


/*
  Callbacks containing primitive types.
  
  These callbacks get passed an sp_error that needs to be casted around.
*/
#define DEFINE_SPERROR_HANDLERS(name) \
  static VALUE ruby_##name(void *error)\
  {\
    return EVENT_ARRAY(#name, 1, INT2FIX((sp_error) error));\
  }\
  static void c_##name(sp_session *session_ptr, sp_error error)\
  {\
    EVENT_CREATE(DATA_HANDLER(session_ptr), ruby_##name, (void*) error);\
  }

DEFINE_SPERROR_HANDLERS(logged_in);
DEFINE_SPERROR_HANDLERS(connection_error);
DEFINE_SPERROR_HANDLERS(streaming_error);


/*
  Callbacks containing complex data.
  
  These callbacks are passed strings which need to be malloc’d/freed.
*/
#define DEFINE_MESSAGE_HANDLERS(name) \
  static VALUE ruby_##name(void *msg)\
  {\
    VALUE message = rb_str_new2((char*) msg);\
    xfree(msg);\
    return EVENT_ARRAY(#name, 1, message);\
  }\
  static void c_##name(sp_session *session_ptr, const char *message)\
  {\
    char *data = ALLOC_N(char, strlen(message) + 1);\
    EVENT_CREATE(DATA_HANDLER(session_ptr), ruby_##name, (void*) strcpy(data, message));\
  }

DEFINE_MESSAGE_HANDLERS(log_message);
DEFINE_MESSAGE_HANDLERS(message_to_user);


const sp_session_callbacks HALLON_SESSION_CALLBACKS = 
{
 .logged_in              = c_logged_in,
 .logged_out             = c_logged_out,
 .metadata_updated       = c_metadata_updated,
 .connection_error       = c_connection_error,
 .message_to_user        = c_message_to_user,
 .notify_main_thread     = c_notify_main_thread,
 .music_delivery         = NULL,
 .play_token_lost        = c_play_token_lost,
 .log_message            = c_log_message,
 .end_of_track           = c_end_of_track,
 .streaming_error        = c_streaming_error,
 .userinfo_updated       = c_userinfo_updated,
 .start_playback         = c_start_playback,
 .stop_playback          = c_stop_playback,
 .get_audio_buffer_stats = NULL
};