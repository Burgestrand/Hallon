#ifndef CALLBACKS_H_HPVSGQG0
#define CALLBACKS_H_HPVSGQG0

/* Firing arbitrary events from ruby */
VALUE hn_session_fire(void *);

/* Session callback methods */
extern const sp_session_callbacks HALLON_SESSION_CALLBACKS;

#endif