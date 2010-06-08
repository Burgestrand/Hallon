#include <ruby.h>
#include <pthread.h>

#ifdef HAVE_LIBSPOTIFY_API_H
#  include <libspotify/api.h>
#else
#  include <spotify/api.h>
#endif

#define Data_Set_Ptr(obj, type, var) do {\
  Check_Type(obj, T_DATA);\
  *((type **) DATA_PTR(obj)) = var;\
} while (0)

#define Data_Get_Ptr(obj, type, var) do {\
  Check_Type(obj, T_DATA);\
  var = *((type **) DATA_PTR(obj));\
  if ( ! var)\
  {\
    rb_raise(eError, "Invalid %s* target", #type);\
  }\
} while (0)

// Statement Expressions: a gcc extension
#define Data_Make_Obj(klass, type, ptr) ({\
  VALUE _obj = rb_funcall3(klass, rb_intern("allocate"), 0, NULL);\
  Data_Set_Ptr(_obj, type, ptr);\
  rb_funcall2(_obj, rb_intern("initialize"), 0, NULL);\
  _obj;\
})

// API Hierarchy
static VALUE mHallon;

  // Error exception
  static VALUE eError;
  
  // Classes
  static VALUE cSession;
  static VALUE cPlaylistContainer;
  static VALUE cPlaylist;
  static VALUE cTrack;
  static VALUE cLink;
  
// Lock variables to make spotify API synchronous
static pthread_mutex_t hallon_mutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t hallon_cond   = PTHREAD_COND_INITIALIZER;

// global error variable (used in spotify callbacks to signal state)
static sp_error callback_error = SP_ERROR_OK;
  
/**
 * Helper methods
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

// convert ruby type to string
static const char *rb2str(VALUE type)
{
  switch (TYPE(type))
  {
    case T_NIL: return "NIL";
    case T_OBJECT: return "OBJECT";
    case T_CLASS: return "CLASS";
    case T_MODULE: return "MODULE";
    case T_FLOAT: return "FLOAT";
    case T_STRING: return "STRING";
    case T_REGEXP: return "REGEXP";
    case T_ARRAY: return "ARRAY";
    case T_HASH: return "HASH";
    case T_STRUCT: return "STRUCT";
    case T_BIGNUM: return "BIGNUM";
    case T_FIXNUM: return "FIXNUM";
    case T_FILE: return "FILE";
    case T_TRUE: return "TRUE";
    case T_FALSE: return "FALSE";
    case T_DATA: return "DATA";
    case T_SYMBOL: return "SYMBOL";
    case T_ICLASS: return "ICLASS";
    case T_MATCH: return "MATCH";
    case T_UNDEF: return "UNDEF";
    case T_NODE: return "NODE";
  }
  
  return "UNDEFINED";
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * End helper methods
 **/

// first time this callback is executed is *before* the sp_session_init 
// function returns (and before the pointer is assigned)
static void callback_notify(sp_session *session)
{
  int timeout = -1;
  sp_session_process_events(session, &timeout);
}

static void callback_logged_in(sp_session *session, sp_error error)
{
  pthread_mutex_lock(&hallon_mutex);
  callback_error = error;
  pthread_cond_signal(&hallon_cond);
  pthread_mutex_unlock(&hallon_mutex); //really?
}
 
static void callback_logged_out(sp_session *session)
{
  /**
   * TODO:
   * This can be called at any time. We must figure out if we called logout
   * manually, or if it is an error. If manually: release locks and signal,
   * if not we should raise an exception in the thread that is using this session.
   */
  pthread_mutex_lock(&hallon_mutex);
  pthread_cond_signal(&hallon_cond);
  pthread_mutex_unlock(&hallon_mutex);
}

static void callback_metadata_updated(sp_session *session)
{}

static void callback_log(sp_session *session, const char *data)
{}

static void callback_message_to_user(sp_session *session, const char *message)
{}

static void callback_connection_error(sp_session *session, sp_error error)
{}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * End session callbacks
 **/

static void callback_playlist_added(sp_playlistcontainer *pc, sp_playlist *playlist, int pos, void *container)
{
  //fprintf(stderr, "\ncontainer (playlist added)");
}

static void callback_playlist_removed(sp_playlistcontainer *pc, sp_playlist *playlist, int pos, void *container)
{}

static void callback_playlist_moved(sp_playlistcontainer *pc, sp_playlist *playlist, int pos, int new_pos, void *container)
{}

static void callback_container_loaded(sp_playlistcontainer *pc, void *container)
{
  //fprintf(stderr, "\ncontainer loaded");
}

static sp_playlistcontainer_callbacks g_playlistcontainer_callbacks = {
  .playlist_added = callback_playlist_added,
  .playlist_removed = callback_playlist_removed,
  .playlist_moved = callback_playlist_moved,
  .container_loaded = callback_container_loaded,
};

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * End container callbacks
 **/

static void callback_tracks_added(sp_playlist *pl, sp_track *const *tracks, int num_tracks, int position, void *userdata)
{}

static void callback_tracks_removed(sp_playlist *pl, const int *tracks, int num_tracks, void *userdata)
{}

static void callback_tracks_moved(sp_playlist *pl, const int *tracks, int num_tracks, int new_position, void *userdata)
{}

static void callback_playlist_renamed(sp_playlist *pl, void *userdata)
{}

static void callback_playlist_state_changed(sp_playlist *pl, void *userdata)
{
  VALUE playlist = (VALUE) userdata;
  //fprintf(stderr, "\nplaylist state change");
}

static void callback_playlist_update_in_progress(sp_playlist *pl, bool done, void *userdata)
{
  //fprintf(stderr, "\nplaylist update (done: %d)", (int) done);
}

// Called by Spotify when any of the tracks in the playlist have new metadata
static void callback_playlist_metadata_updated(sp_playlist *pl, void *userdata)
{
  //fprintf(stderr, "\nplaylist metadata updated");
}

static sp_playlist_callbacks g_playlist_callbacks = {
  .tracks_added = callback_tracks_added,
  .tracks_removed = callback_tracks_removed,
  .tracks_moved = callback_tracks_moved,
  .playlist_renamed = callback_playlist_renamed,
  .playlist_state_changed = callback_playlist_state_changed,
  .playlist_update_in_progress = callback_playlist_update_in_progress,
  .playlist_metadata_updated = callback_playlist_metadata_updated
};

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * End playlist callbacks
 **/

/**
 * Internal method: allocate a pointer to an sp_session.
 */
static VALUE ciSession_alloc(VALUE self)
{
  sp_session **psession;
  return Data_Make_Struct(self, sp_session*, 0, -1, psession);
}

/**
 * call-seq:
 *   login(username, password) -> Session
 * 
 * Logs in to Spotify. Throws an exception if already logged in.
 */
static VALUE cSession_login(VALUE self, VALUE username, VALUE password)
{
  sp_session *session;
  Data_Get_Ptr(self, sp_session, session);
  
  if (sp_session_connectionstate(session) == SP_CONNECTION_STATE_LOGGED_IN)
  {
    rb_raise(eError, "already logged in");
  }
  
  pthread_mutex_lock(&hallon_mutex);
  sp_error error = sp_session_login(session, StringValuePtr(username), StringValuePtr(password));
  
  if (error != SP_ERROR_OK)
  {
    pthread_mutex_unlock(&hallon_mutex);
    rb_raise(eError, "%s", sp_error_message(error));
  }
  
  // wait for login to finish
  pthread_cond_wait(&hallon_cond, &hallon_mutex);
  
  // check callback error
  if (callback_error != SP_ERROR_OK)
  {
    pthread_mutex_unlock(&hallon_mutex);
    rb_raise(eError, "%s", sp_error_message(error));
  }
  
  pthread_mutex_unlock(&hallon_mutex); // unlock! really? is it locked?
  
  return self;
}

/**
 * call-seq:
 *   logout -> Session
 * 
 * Logs out the current user. Throws an exception if not logged in.
 */
static VALUE cSession_logout(VALUE self)
{
  sp_session *session;
  Data_Get_Ptr(self, sp_session, session);
  
  if (sp_session_connectionstate(session) != SP_CONNECTION_STATE_LOGGED_IN)
  {
    rb_raise(eError, "tried to logout when not logged in");
  }
  
  pthread_mutex_lock(&hallon_mutex);
  sp_error error = sp_session_logout(session);
  
  if (error != SP_ERROR_OK)
  {
    pthread_mutex_unlock(&hallon_mutex);
    rb_raise(eError, "%s", sp_error_message(error));
  }
  
  // wait until logged out
  pthread_cond_wait(&hallon_cond, &hallon_mutex);
  pthread_mutex_unlock(&hallon_mutex);
  
  return self;
}

/**
 * call-seq:
 *   sp_process -> Fixnum
 * 
 * Processes any pending spotify events.
 * <br><br>
 * Returns the minimum time (milliseconds) until it *must* be done again.
 */
static VALUE cSession_process(VALUE self)
{
  sp_session *session;
  Data_Get_Ptr(self, sp_session, session);
  int timeout = -1;
  sp_session_process_events(session, &timeout);
  return rb_float_new(timeout / 1000.0);
}

/**
 * call-seq:
 *   logged_in? -> true or false
 * 
 * true if the current session is logged in.
 */
static VALUE cSession_logged_in(VALUE self)
{
  sp_session *session;
  Data_Get_Ptr(self, sp_session, session);
  return sp_session_connectionstate(session) == SP_CONNECTION_STATE_LOGGED_IN ? Qtrue : Qfalse;
}

/**
 * call-seq:
 *   playlists -> PlaylistContainer
 * 
 * Returns the PlaylistContainer for the currently logged in user.
 */
static VALUE cSession_playlists(VALUE self)
{
  return rb_funcall3(cPlaylistContainer, rb_intern("new"), 1, &self);
}


/**
 * call-seq:
 *   initialize(application_key, user_agent = 'Hallon', cache_path = 'tmp', settings_path = 'tmp')
 * 
 * See sp_session_init[https://developer.spotify.com/en/libspotify/docs/group__session.html#ga3d50584480c8a5b554ba5d1b8d09b8b] for more details.
 */
static VALUE cSession_initialize(int argc, VALUE *argv, VALUE self)
{
  VALUE v_appkey, v_user_agent, v_cache_path, v_settings_path;
  
  // default arguments scanning
  switch (rb_scan_args(argc, argv, "13", &v_appkey, &v_user_agent, &v_cache_path, &v_settings_path))
  {
    case 1: v_user_agent = rb_str_new2("Hallon");
    case 2: v_cache_path = rb_str_new2("tmp");
    case 3: v_settings_path = rb_str_new2("tmp");
  }
  
  // check argument types
  Check_Type(v_appkey, T_STRING);
  Check_Type(v_user_agent, T_STRING);
  Check_Type(v_cache_path, T_STRING);
  Check_Type(v_settings_path, T_STRING);
  
  // set callbacks
  sp_session_callbacks callbacks =
  {
    .logged_in = callback_logged_in, 
    .logged_out = callback_logged_out,
    .metadata_updated = callback_metadata_updated,
    .connection_error = callback_connection_error,
    .message_to_user = callback_message_to_user,
    .notify_main_thread = callback_notify,
    .music_delivery = NULL,
    .play_token_lost = NULL,
    .log_message = callback_log,
    .end_of_track = NULL
  };
  
  // set configuration
  sp_session_config config = 
  {
    SPOTIFY_API_VERSION,
    StringValuePtr(v_cache_path),
    StringValuePtr(v_settings_path),
    RSTRING_PTR(v_appkey),
    RSTRING_LEN(v_appkey),
    StringValuePtr(v_user_agent),
    &callbacks, // callbacks
    NULL, // user supplied data
  };

  sp_session **psession;
  Data_Get_Struct(self, sp_session*, psession);
  sp_error error = sp_session_init(&config, &(*psession));
  
  if (error != SP_ERROR_OK)
  {
    rb_raise(eError, "%s", sp_error_message(error));
  }
  
  return self;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * End session methods
 **/

/**
 * Internal method: allocate a pointer to an sp_playlistcontainer.
 */
static VALUE ciPlaylistContainer_alloc(VALUE self)
{
  sp_playlistcontainer **pcontainer;
  return Data_Make_Struct(self, sp_playlistcontainer*, 0, -1, pcontainer);
}

/**
 * call-seq:
 *   length -> Fixnum
 * 
 * Returns the number of playlists in the container.
 */
static VALUE cPlaylistContainer_length(VALUE self)
{
  sp_playlistcontainer *container;
  Data_Get_Ptr(self, sp_playlistcontainer, container);
  return INT2FIX(sp_playlistcontainer_num_playlists(container));
}

/**
 * call-seq:
 *   add(String) -> Playlist
 * 
 * Create a new Playlist with the given name and put it into the container.
 */
static VALUE cPlaylistContainer_add(VALUE self, VALUE name)
{
  VALUE regx = rb_str_new2("[^ ]");
  
  // Validate playlist name
  Check_Type(name, T_STRING);
  
  // Validate name length
  if (FIX2INT(rb_funcall3(name, rb_intern("length"), 0, NULL)) > 255)
  {
    rb_raise(rb_eArgError, "Playlist name length must be less than 256 characters");
  }
  else if ( ! RTEST(rb_funcall3(name, rb_intern("match"), 1, &regx)))
  {
    rb_raise(rb_eArgError, "Playlist name must have at least one non-space character");
  }
  
  // Add playlist to container
  sp_playlistcontainer *container;
  Data_Get_Ptr(self, sp_playlistcontainer, container);
  sp_playlist *playlist = sp_playlistcontainer_add_new_playlist(container, RSTRING_PTR(name));
  
  if ( ! playlist)
  {
    rb_raise(eError, "Playlist creation failed");
  }
  
  return Data_Make_Obj(cPlaylist, sp_playlist, playlist);
}

/**
 * call-seq:
 *   each({ |playlist| block }) -> array
 * 
 * Calls “block” once for each Playlist, passing that Playlist as parameter.
 */
static VALUE cPlaylistContainer_each(VALUE self)
{
  // Make sure we’ve been given a block
  rb_block_given_p();
  
  sp_playlist *playlist;
  sp_playlistcontainer *container;
  Data_Get_Ptr(self, sp_playlistcontainer, container);
  int i = 0, n = sp_playlistcontainer_num_playlists(container);
  VALUE accumulator = rb_ary_new2(n);
  VALUE obj = Qnil;
  
  // Iterate!
  for (i = 0; i < n; ++i)
  {
    playlist = sp_playlistcontainer_playlist(container, i);
    obj = Data_Make_Obj(cPlaylist, sp_playlist, playlist);
    rb_ary_push(accumulator, rb_yield(obj));
  }
  
  return accumulator;
}

/**
 * call-seq:
 *   initialize(Session)
 * 
 * Creates a new PlaylistContainer for the given Session.
 */
static VALUE cPlaylistContainer_initialize(VALUE self, VALUE osession)
{
  sp_session *session;
  Data_Get_Ptr(osession, sp_session, session);
  
  sp_playlistcontainer **pcontainer;
  Data_Get_Struct(self, sp_playlistcontainer*, pcontainer);
  *pcontainer = sp_session_playlistcontainer(session);
  
  sp_playlistcontainer_add_callbacks(*pcontainer, &g_playlistcontainer_callbacks, &self);
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * End playlist container methods
 **/

/**
 * Frees memory for an allocated playlist.
 */
static VALUE ciPlaylist_free(sp_playlist **playlist)
{
  // sp_playlist_remove_callbacks
  xfree(playlist);
}

/**
 * Allocates memory for a new playlist.
 */
static VALUE ciPlaylist_alloc(VALUE self)
{
  sp_playlist **playlist;
  return Data_Make_Struct(self, sp_playlist*, 0, ciPlaylist_free, playlist);
}

/**
 * :nodoc:
 */
static VALUE cPlaylist_initialize(VALUE self)
{
  sp_playlist *playlist;
  Data_Get_Ptr(self, sp_playlist, playlist);
  sp_playlist_add_callbacks(playlist, &g_playlist_callbacks, (void *)self);
}

/**
 * call-seq:
 *   name -> String
 * 
 * Name of the playlist.
 */
static VALUE cPlaylist_name(VALUE self)
{
  sp_playlist *playlist;
  Data_Get_Ptr(self, sp_playlist, playlist);
  return rb_str_new2(sp_playlist_name(playlist));
}

/**
 * call-seq:
 *   length -> Fixnum
 * 
 * Number of tracks in the playlist.
 */
static VALUE cPlaylist_length(VALUE self)
{
  sp_playlist *playlist;
  Data_Get_Ptr(self, sp_playlist, playlist);
  return INT2FIX(sp_playlist_num_tracks(playlist));
}

/**
 * call-seq:
 *   loaded? -> true or false
 * 
 * Returns true if the playlist is loaded.
 */
static VALUE cPlaylist_loaded(VALUE self)
{
  sp_playlist *playlist;
  Data_Get_Ptr(self, sp_playlist, playlist);
  return sp_playlist_is_loaded(playlist) ? Qtrue : Qfalse;
}

/**
 * call-seq:
 *   link -> Link
 * 
 * Return a Link for this playlist.
 */
static VALUE cPlaylist_link(VALUE self)
{
  sp_playlist *playlist;
  Data_Get_Ptr(self, sp_playlist, playlist);
  
  VALUE linkobj = rb_funcall3(cLink, rb_intern("allocate"), 0, NULL);
  sp_link *link = sp_link_create_from_playlist(playlist);
  Data_Set_Ptr(linkobj, sp_link, link);
  
  return linkobj;
}

/**
 * call-seq:
 *   fresh? -> true or false
 * 
 * False if the playlist has pending changes which have not yet been acknowledged by Spotify.
 */
static VALUE cPlaylist_pending(VALUE self)
{
  sp_playlist *playlist;
  Data_Get_Ptr(self, sp_playlist, playlist);
  return sp_playlist_has_pending_changes(playlist) ? Qtrue : Qfalse;
}

/**
 * call-seq:
 *   collaborative? -> true or false
 * 
 * True if the playlist is collaborative.
 */
static VALUE cPlaylist_collaborative(VALUE self)
{
  sp_playlist *playlist;
  Data_Get_Ptr(self, sp_playlist, playlist);
  return sp_playlist_is_collaborative(playlist) ? Qtrue : Qfalse;
}

/**
 * call-seq:
 *   collaborative = true or false
 * 
 * Set collaborative flag for playlist.
 */
static VALUE cPlaylist_set_collaborative(VALUE self, VALUE new)
{
  bool collaborative = ! (new == Qnil || new == Qfalse);
  sp_playlist *playlist;
  Data_Get_Ptr(self, sp_playlist, playlist);
  sp_playlist_set_collaborative(playlist, collaborative);
  return collaborative ? Qtrue : Qfalse;
}

/**
 * call-seq:
 *   clear! -> Playlist
 * 
 * Clear the playlist by removing all tracks from the playlist.
 */
static VALUE cPlaylist_clear(VALUE self)
{
  sp_playlist *playlist = NULL;
  Data_Get_Ptr(self, sp_playlist, playlist);
  int i = 0;
  int numtracks = sp_playlist_num_tracks(playlist);
  int tracks[numtracks];
  
  for (i = 0; i < numtracks; ++i)
  {
    tracks[i] = i;
  }
  
  sp_error error = sp_playlist_remove_tracks(playlist, tracks, numtracks);
  
  if (error != SP_ERROR_OK)
  {
    rb_raise(eError, "%s", sp_error_message(error));
  }
  
  return self;
}

/**
 * call-seq:
 *   push(Track) -> Playlist
 * 
 * Append the Track to the end of the Playlist.
 */
static VALUE cPlaylist_push(VALUE self, VALUE track)
{
  // Check argument
  VALUE pred = rb_funcall3(track, rb_intern("is_a?"), 1, &cTrack);
  
  if (pred != Qtrue)
  {
    rb_raise(eError, "You can only add tracks to a playlist");
  }
  
  // Retrieve session, this is an ugly hack
  VALUE session = rb_funcall3(cSession, rb_intern("instance"), 0, NULL);
  sp_session *psession;
  Data_Get_Ptr(session, sp_session, psession);
  
  // Retrieve playlist
  sp_playlist *playlist;
  Data_Get_Ptr(self, sp_playlist, playlist);
  
  // Retrieve track
  sp_track *ptrack;
  Data_Get_Ptr(track, sp_track, ptrack);
  
  // Build array
  sp_track **ptracks = &ptrack;
  
  // .... and add! :D!
  sp_playlist_add_tracks(playlist, (const sp_track**) ptracks, 1, sp_playlist_num_tracks(playlist), psession);
  
  return self;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * End playlist methods
 **/

/**
 * Frees memory for a Link.
 */
static VALUE ciLink_free(sp_link **plink)
{
  if (*plink) sp_link_release(*plink);
  xfree(plink);
}

/**
 * Allocates memory for a new Link.
 */
static VALUE ciLink_alloc(VALUE self)
{
  sp_link **plink;
  return Data_Make_Struct(self, sp_link*, 0, ciLink_free, plink);
}

/**
 * call-seq:
 *   initialize(String)
 * 
 * Parses a Spotify URI into a Link. Throws an ArgumentError if unparseable.
 */
static VALUE cLink_initialize(VALUE self, VALUE uri)
{
  Check_Type(uri, T_STRING);
  
  sp_link **plink;
  Data_Get_Struct(self, sp_link*, plink);
  *plink = sp_link_create_from_string(RSTRING_PTR(uri));
  
  if ( ! *plink)
  {
    rb_raise(rb_eArgError, "Spotify URI could not be parsed");
  }
}

/**
 * call-seq:
 *   type -> Symbol
 * 
 * One of: invalid, track, album, artist, search and playlist.
 */
static VALUE cLink_type(VALUE self)
{
  sp_link *link;
  Data_Get_Ptr(self, sp_link, link);
  
  static const char *LINK_TYPES[] = {
    "invalid", "track", "album", "artist", "search", "playlist"
  };
  
  VALUE str = rb_str_new2(LINK_TYPES[sp_link_type(link)]);
  
  return rb_funcall3(str, rb_intern("to_sym"), 0, NULL);
}

/**
 * call-seq:
 *   to_str -> String
 * 
 * Returns the Link as a Spotify URI.
 */
static VALUE cLink_to_str(VALUE self)
{
  char spotify_uri[256];
  sp_link *link;
  Data_Get_Ptr(self, sp_link, link);
  
  if (0 > sp_link_as_string(link, spotify_uri, sizeof(spotify_uri)))
  {
    rb_raise(eError, "Failed to render Spotify URI from link");
  }
  
  return rb_str_new2(spotify_uri);
}

/**
 * call-seq:
 *   to_obj -> Track, Album, Artist, Search or Playlist
 * 
 * Return an object (Track, Album, Artist, Search, Playlist) representing the Link.
 */
static VALUE cLink_to_obj(VALUE self)
{
  sp_link *link;
  Data_Get_Ptr(self, sp_link, link);
  sp_linktype type = sp_link_type(link);
  
  if (type == SP_LINKTYPE_TRACK)
  {
    sp_track *track = sp_link_as_track(link);
    return Data_Make_Obj(cTrack, sp_track, track);
  }
  else
  {
    VALUE type = rb_funcall3(self, rb_intern("type"), 0, NULL);
    rb_raise(eError, "Cannot convert Link of type “%s” to object", RSTRING_PTR(type));
  }
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * End link methods
 **/

/**
 * Frees memory for a Track.
 */
static VALUE ciTrack_free(sp_track **ptrack)
{
  sp_track_release(*ptrack);
  xfree(ptrack);
}

/**
 * Allocates memory for a new Track.
 */
static VALUE ciTrack_alloc(VALUE self)
{
  sp_track **ptrack;
  return Data_Make_Struct(self, sp_track*, 0, ciTrack_free, ptrack);
}

/**
 * Initializes the track by adding a reference to the internal track pointer.
 */
static VALUE cTrack_initialize(VALUE self)
{
  sp_track *track;
  Data_Get_Ptr(self, sp_track, track);
  sp_track_add_ref(track);
}

/**
 * call-seq:
 *   name -> String
 * 
 * Name of the Track.
 */
static VALUE cTrack_name(VALUE self)
{
  sp_track *track;
  Data_Get_Ptr(self, sp_track, track);
  return rb_str_new2(sp_track_name(track));
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * End track methods
 **/

/**
 * 
 */
void Init_hallon()
{  
  mHallon = rb_define_module("Hallon");
    /* The libspotify version Hallon was compiled with. */
    rb_define_const(mHallon, "API_VERSION", INT2FIX(SPOTIFY_API_VERSION));
  
  // Error Exception
  eError = rb_define_class_under(mHallon, "Error", rb_eStandardError);
  
  // Session class
  cSession = rb_define_class_under(mHallon, "Session", rb_cObject);
  rb_define_alloc_func(cSession, ciSession_alloc);
  rb_define_method(cSession, "initialize", cSession_initialize, -1);
  rb_define_private_method(cSession, "sp_process", cSession_process, 0);
  rb_define_method(cSession, "login", cSession_login, 2);
  rb_define_method(cSession, "logout", cSession_logout, 0);
  rb_define_method(cSession, "logged_in?", cSession_logged_in, 0);
  rb_define_method(cSession, "playlists", cSession_playlists, 0);
  
  // PlaylistContainer class
  cPlaylistContainer = rb_define_class_under(mHallon, "PlaylistContainer", rb_cObject);
  rb_define_alloc_func(cPlaylistContainer, ciPlaylistContainer_alloc);
  rb_define_method(cPlaylistContainer, "initialize", cPlaylistContainer_initialize, 1);
  rb_define_method(cPlaylistContainer, "length", cPlaylistContainer_length, 0);
  rb_define_method(cPlaylistContainer, "add", cPlaylistContainer_add, 1);
  rb_define_method(cPlaylistContainer, "each", cPlaylistContainer_each, 0);
  
  // Playlist class
  cPlaylist = rb_define_class_under(mHallon, "Playlist", rb_cObject);
  rb_define_alloc_func(cPlaylist, ciPlaylist_alloc);
  rb_define_method(cPlaylist, "initialize", cPlaylist_initialize, 0);
  rb_define_method(cPlaylist, "name", cPlaylist_name, 0);
  rb_define_method(cPlaylist, "length", cPlaylist_length, 0);
  rb_define_method(cPlaylist, "loaded?", cPlaylist_loaded, 0);
  rb_define_method(cPlaylist, "link", cPlaylist_link, 0);
  rb_define_method(cPlaylist, "pending?", cPlaylist_pending, 0);
  rb_define_method(cPlaylist, "collaborative?", cPlaylist_collaborative, 0);
  rb_define_method(cPlaylist, "collaborative=", cPlaylist_set_collaborative, 1);
  rb_define_method(cPlaylist, "clear!", cPlaylist_clear, 0);
  rb_define_method(cPlaylist, "push", cPlaylist_push, 1);
  
  // Link class
  cLink = rb_define_class_under(mHallon, "Link", rb_cObject);
  rb_define_alloc_func(cLink, ciLink_alloc);
  rb_define_method(cLink, "initialize", cLink_initialize, 1);
  rb_define_method(cLink, "type", cLink_type, 0);
  rb_define_method(cLink, "to_str", cLink_to_str, 0);
  rb_define_method(cLink, "to_obj", cLink_to_obj, 0);
  
  // Track class
  cTrack = rb_define_class_under(mHallon, "Track", rb_cObject);
  rb_define_alloc_func(cTrack, ciTrack_alloc);
  rb_define_method(cTrack, "initialize", cTrack_initialize, 0);
  rb_define_method(cTrack, "name", cTrack_name, 0);
}