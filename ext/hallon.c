#include "hallon.h"

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
  static VALUE cUser;
  
// Lock variables to make spotify API synchronous
static pthread_mutex_t hallon_mutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t hallon_cond   = PTHREAD_COND_INITIALIZER;

// global error variable (used in spotify callbacks to signal state)
static sp_error callback_error = SP_ERROR_OK;
  
/**
 * Helper methods
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static VALUE mkLink(sp_link *link)
{
  VALUE obj = rb_funcall3(cLink, rb_intern("allocate"), 0, NULL);
  Data_Set_Ptr(obj, sp_link, link);
  return obj;
}

static VALUE assert_playlist_name(VALUE name)
{
  // Validate type
  Check_Type(name, T_STRING);
  
  // Validate format-regex
  VALUE regx = rb_str_new2("[^ ]");
  
  // Validate name length
  if (FIX2INT(rb_funcall3(name, rb_intern("length"), 0, NULL)) > 255)
  {
    rb_raise(rb_eArgError, "Playlist name length must be less than 256 characters");
  }
  else if ( ! RTEST(rb_funcall3(name, rb_intern("match"), 1, &regx)))
  {
    rb_raise(rb_eArgError, "Playlist name must have at least one non-space character");
  }
  
  return Qtrue;
}

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
  //fprintf(stderr, "\nprocess: %s", rb_obj_classname((VALUE) sp_session_userdata(session)));
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
  sp_session *session = DATA_PPTR(self, sp_session);
  
  if (sp_session_connectionstate(session) == SP_CONNECTION_STATE_LOGGED_IN)
  {
    rb_raise(eError, "already logged in");
  }
  
  pthread_mutex_lock(&hallon_mutex);
  sp_error error = sp_session_login(session, StringValuePtr(username), StringValuePtr(password));
  
  if (error != SP_ERROR_OK)
  {
    pthread_mutex_unlock(&hallon_mutex);
    rb_raise(eError, "login request failure (%s)", sp_error_message(error));
  }
  
  // wait for login to finish
  pthread_cond_wait(&hallon_cond, &hallon_mutex);
  
  // check callback error
  if (callback_error != SP_ERROR_OK)
  {
    pthread_mutex_unlock(&hallon_mutex);
    rb_raise(eError, "login response failure (%s)", sp_error_message(error));
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
  sp_session *session = DATA_PPTR(self, sp_session);
  
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
  int timeout = -1;
  sp_session_process_events(DATA_PPTR(self, sp_session), &timeout);
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
  return sp_session_connectionstate(DATA_PPTR(self, sp_session)) 
         == SP_CONNECTION_STATE_LOGGED_IN ? Qtrue : Qfalse;
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
 *   user -> User
 * 
 * Retrieve the User for the logged-in session.
 */
static VALUE cSession_user(VALUE self)
{
  return Data_Make_Obj(cUser, sp_user, sp_session_user(DATA_PPTR(self, sp_session)));
}

/**
 * :nodoc:
 *
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
    .api_version = SPOTIFY_API_VERSION,
    .cache_location = StringValuePtr(v_cache_path),
    .settings_location = StringValuePtr(v_settings_path),
    .application_key = RSTRING_PTR(v_appkey),
    .application_key_size = RSTRING_LEN(v_appkey),
    .user_agent = StringValuePtr(v_user_agent),
    .callbacks = &callbacks,
    .userdata = (void*)self,
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
 *   container.length -> Fixnum
 * 
 * Returns the number of playlists in the container.
 */
static VALUE cPlaylistContainer_length(VALUE self)
{
  return INT2FIX(sp_playlistcontainer_num_playlists(DATA_PPTR(self, sp_playlistcontainer)));
}

/**
 * call-seq:
 *   container.push(name or Playlist) -> Playlist
 * 
 * Accepts either a string or a Playlist. If a string is given, a new playlist
 * is created with the given name.
 */
static VALUE cPlaylistContainer_add(VALUE self, VALUE obj)
{
  sp_playlistcontainer *pc = DATA_PPTR(self, sp_playlistcontainer);
  sp_playlist *playlist = NULL;
  
  if (CLASS_OF(obj) == cPlaylist)
  {
    playlist = sp_playlistcontainer_add_playlist(
      pc, 
      sp_link_create_from_playlist(DATA_PPTR(obj, sp_playlist))
    );
  }
  else if (TYPE(obj) == T_STRING)
  {
    assert_playlist_name(obj);
    playlist = sp_playlistcontainer_add_new_playlist(pc, RSTRING_PTR(obj));
  }
  else
  {
    rb_raise(rb_eTypeError, "wrong argument type %s (expected String or Playlist)",
      rb_obj_classname(obj)
    );
  }
  
  if ( ! playlist)
  {
    rb_raise(eError, "playlist creation failed");
  }

  return Data_Make_Obj(cPlaylist, sp_playlist, playlist);
}

/**
 * call-seq:
 *   container.at(index) -> Playlist or nil
 * 
 * Returns the Playlist at index. Negative indexes starts from the end. Returns nil if the index is out of range.
 */
static VALUE cPlaylistContainer_at(VALUE self, VALUE index)
{
  Check_Type(index, T_FIXNUM);
  
  sp_playlistcontainer *container = DATA_PPTR(self, sp_playlistcontainer);
  
  int pos = FIX2INT(index),
      total = sp_playlistcontainer_num_playlists(container);
  
  if (pos < 0) pos = total + pos;
  if (pos < 0 || pos >= total) return Qnil;
  
  sp_playlist *playlist = sp_playlistcontainer_playlist(container, pos);
  
  return Data_Make_Obj(cPlaylist, sp_playlist, playlist);
}

/**
 * call-seq:
 *   container.delete_at(index) -> Playlist or nil
 * 
 * Remove the playlist at <code>index</code>. <code>index</code> may be negative.
 */
static VALUE cPlaylistContainer_delete_at(VALUE self, VALUE index) 
{
  Check_Type(index, T_FIXNUM);
  
  sp_playlistcontainer *pc = DATA_PPTR(self, sp_playlistcontainer);
  
  int pindex = FIX2INT(index),
      length = sp_playlistcontainer_num_playlists(pc);
      
  if (pindex < 0) pindex = length + pindex;
  if (pindex < 0 || pindex >= length) return Qnil;
  
  sp_playlist *playlist = sp_playlistcontainer_playlist(pc, pindex);
  sp_error error = sp_playlistcontainer_remove_playlist(pc, pindex);

  if (error != SP_ERROR_OK)
  {
    rb_raise(eError, "removing playlist %i failed: %s", pindex, sp_error_message(error));
  }
  
  return Data_Make_Obj(cPlaylist, sp_playlist, playlist);
}

/**
 * call-seq:
 *   PlaylistContainer.new(Session)
 * 
 * Creates a new PlaylistContainer for the given Session.
 */
static VALUE cPlaylistContainer_initialize(VALUE self, VALUE osession)
{
  sp_playlistcontainer **pcontainer;
  Data_Get_Struct(self, sp_playlistcontainer*, pcontainer);
  *pcontainer = sp_session_playlistcontainer(DATA_PPTR(osession, sp_session));
  
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
  sp_playlist_release(*playlist);
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
 * Initializes the playlist.
 */
static VALUE cPlaylist_initialize(VALUE self)
{
  sp_playlist *playlist = DATA_PPTR(self, sp_playlist);
  sp_playlist_add_ref(playlist);
  sp_playlist_add_callbacks(playlist, &g_playlist_callbacks, (void *)self);
}

/**
 * call-seq:
 *   playlist.name -> String
 * 
 * Name of the playlist.
 */
static VALUE cPlaylist_name(VALUE self)
{
  return rb_str_new2(sp_playlist_name(DATA_PPTR(self, sp_playlist)));
}

/**
 * call-seq:
 *   playlist.length -> Fixnum
 * 
 * Number of tracks in the playlist.
 */
static VALUE cPlaylist_length(VALUE self)
{
  return INT2FIX(sp_playlist_num_tracks(DATA_PPTR(self, sp_playlist)));
}

/**
 * call-seq:
 *   playlist.loaded? -> true or false
 * 
 * Returns true if the playlist is loaded.
 */
static VALUE cPlaylist_loaded(VALUE self)
{
  return sp_playlist_is_loaded(DATA_PPTR(self, sp_playlist)) ? Qtrue : Qfalse;
}

/**
 * call-seq:
 *   playlist.to_link -> Link
 * 
 * Return a Link for this playlist.
 */
static VALUE cPlaylist_to_link(VALUE self)
{
  return mkLink(sp_link_create_from_playlist(DATA_PPTR(self, sp_playlist)));
}

/**
 * call-seq:
 *   playlist.pending? -> true or false
 * 
 * False if the playlist has pending changes which have not yet been acknowledged by Spotify.
 */
static VALUE cPlaylist_pending(VALUE self)
{
  return sp_playlist_has_pending_changes(DATA_PPTR(self, sp_playlist)) ? Qtrue : Qfalse;
}

/**
 * call-seq:
 *   playlist.collaborative? -> true or false
 * 
 * True if the playlist is collaborative.
 */
static VALUE cPlaylist_collaborative(VALUE self)
{
  return sp_playlist_is_collaborative(DATA_PPTR(self, sp_playlist)) ? Qtrue : Qfalse;
}

/**
 * call-seq:
 *   playlist.collaborative = true or false
 * 
 * Set collaborative flag for playlist.
 */
static VALUE cPlaylist_set_collaborative(VALUE self, VALUE truth)
{
  bool collaborative = RTEST(truth);
  sp_playlist_set_collaborative(DATA_PPTR(self, sp_playlist), collaborative);
  return collaborative ? Qtrue : Qfalse;
}

/**
 * call-seq:
 *   playlist.at(index) -> Track or nil
 * 
 * Returns the Track at index. Negative index starts from the end of the playlist. Returns nil if the index is out of range.
 */
static VALUE cPlaylist_at(VALUE self, VALUE index)
{
  Check_Type(index, T_FIXNUM);
  int pos = FIX2INT(index);
  
  sp_playlist *playlist = DATA_PPTR(self, sp_playlist);
  
  if (pos < 0) pos = sp_playlist_num_tracks(playlist) + pos;
  if (pos < 0 || pos >= sp_playlist_num_tracks(playlist)) return Qnil;
  
  sp_track *track = sp_playlist_track(playlist, pos);
  
  return Data_Make_Obj(cTrack, sp_track, track);
}

/**
 * call-seq:
 *   playlist.insert(index, Track…) -> Playlist
 * 
 * Insert the given tracks before the element with the given index. Accepts negative indexes.
 */
static VALUE cPlaylist_insert(int argc, VALUE *argv, VALUE self)
{
  VALUE index, track, tracks;
  long i;

  // argument building
  rb_scan_args(argc, argv, "2*", &index, &track, &tracks);
  Check_Type(index, T_FIXNUM);
  tracks = rb_ary_unshift(tracks, track);
  
  // iterate through tracks to collect pointers
  sp_track *ptracks[RARRAY_LEN(tracks)];
  for (i = 0; i < RARRAY_LEN(tracks); i++)
  {
    track = RARRAY_PTR(tracks)[i];
    if (CLASS_OF(track) != cTrack)
    {
      rb_raise(rb_eTypeError, "wrong argument type %s (expected %s) on position %ld", 
        rb_obj_classname(track), rb_obj_classname(cTrack), i);
    }
    
    ptracks[i] = DATA_PPTR(track, sp_track);
  }
  
  // Retrieve session, this is an ugly hack
  VALUE session = rb_funcall3(cSession, rb_intern("instance"), 0, NULL);
  sp_session *psession = DATA_PPTR(session, sp_session);
  
  // Retrieve playlist
  sp_playlist *playlist = DATA_PPTR(self, sp_playlist);
  
  // double-check the index
  int cindex = FIX2INT(index);
  if (cindex < 0) cindex = sp_playlist_num_tracks(playlist) + cindex;
  if (cindex < 0 || cindex > sp_playlist_num_tracks(playlist)) rb_raise(rb_eArgError, "index %d out of range", cindex);
  
  // .... and add! :D!
  sp_error error = sp_playlist_add_tracks(playlist, (const sp_track **) ptracks, (int) RARRAY_LEN(tracks), cindex, psession);
  
  if (error != SP_ERROR_OK)
  {
    rb_raise(eError, "error adding tracks: %s", sp_error_message(error));
  }
  
  return self;
}

/**
 * call-seq:
 *   playlist.remove([index, …]) -> Playlist
 * 
 * Walks through the set of indexes, removing the Track at each respective index.
 */
static VALUE cPlaylist_remove(VALUE self, VALUE indexes)
{
  VALUE pos;
  long i, idx, numtracks;
  
  sp_playlist *playlist = DATA_PPTR(self, sp_playlist);
  numtracks = sp_playlist_num_tracks(playlist);
  
  Check_Type(indexes, T_ARRAY);
  indexes = rb_funcall3(indexes, rb_intern("uniq"), 0, NULL);
  
  int tracks[RARRAY_LEN(indexes)];
  
  for (i = 0; i < RARRAY_LEN(indexes); ++i)
  {
    pos = RARRAY_PTR(indexes)[i];
    
    if ( ! FIXNUM_P(pos))
    {
      rb_raise(rb_eTypeError, "wrong argument type %s (expected Fixnum) at index %ld", rb_obj_classname(pos), i);
    }
    
    idx = FIX2INT(pos);
    if (idx < 0 || idx >= numtracks)
    {
      rb_raise(rb_eArgError, "index at position %ld out of range", i);
    }

    tracks[i] = FIX2INT(pos);
  }
  
  sp_error error = sp_playlist_remove_tracks(playlist, tracks, (int) RARRAY_LEN(indexes));
  
  if (error != SP_ERROR_OK)
  {
    rb_raise(eError, "error removing tracks: %s", sp_error_message(error));
  }
  
  return self;
}

/**
 * call-seq:
 *   playlist.name = String
 * 
 * Renames the Playlist.
 */
static VALUE cPlaylist_set_name(VALUE self, VALUE name)
{
  assert_playlist_name(name);
  
  sp_error error = sp_playlist_rename(DATA_PPTR(self, sp_playlist), StringValuePtr(name));
  
  if (error != SP_ERROR_OK)
  {
    rb_raise(eError, "playlist rename failed: %s", sp_error_message(error));
  }
  
  return name;
}

/**
 * call-seq:
 *   playlist.owner -> User
 * 
 * Owner (User) of the Playlist.
 */
static VALUE cPlaylist_owner(VALUE self)
{
  return Data_Make_Obj(cUser, sp_user, sp_playlist_owner(DATA_PPTR(self, sp_playlist)));
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * End playlist methods
 **/

/**
 * Frees memory for a Link.
 */
static VALUE ciLink_free(sp_link **plink)
{
  if (*plink) sp_link_release(*plink); // if link was unparsable it won’t exist
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
  static const char *LINK_TYPES[] = {
    "invalid", "track", "album", "artist", "search", "playlist"
  };
  
  VALUE str = rb_str_new2(LINK_TYPES[sp_link_type(DATA_PPTR(self, sp_link))]);
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

  if (0 > sp_link_as_string(DATA_PPTR(self, sp_link), spotify_uri, sizeof(spotify_uri)))
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
  sp_link *link = DATA_PPTR(self, sp_link);
  sp_linktype type = sp_link_type(link);
  
  if (type == SP_LINKTYPE_TRACK)
  {
    sp_track *track = sp_link_as_track(link);
    return Data_Make_Obj(cTrack, sp_track, track);
  }
  else if (type == SP_LINKTYPE_PLAYLIST)
  {
    VALUE session = rb_funcall3(cSession, rb_intern("instance"), 0, NULL);
    sp_playlist *playlist = sp_playlist_create(DATA_PPTR(session, sp_session), link);
    return Data_Make_Obj(cPlaylist, sp_playlist, playlist);
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
  sp_track_add_ref(DATA_PPTR(self, sp_track));
}

/**
 * call-seq:
 *   name -> String
 * 
 * Name of the Track.
 */
static VALUE cTrack_name(VALUE self)
{
  return rb_str_new2(sp_track_name(DATA_PPTR(self, sp_track)));
}

/**
 * call-seq:
 *   loaded? -> true or false
 * 
 * True if the track has loaded.
 */
static VALUE cTrack_loaded(VALUE self)
{
  return sp_track_is_loaded(DATA_PPTR(self, sp_track)) ? Qtrue : Qfalse;
}

/**
 * call-seq:
 *   available? -> true or false
 * 
 * True if the track is available for playback.
 */
static VALUE cTrack_available(VALUE self)
{
  return sp_track_is_available(DATA_PPTR(self, sp_track)) ? Qtrue : Qfalse;
}

/**
 * call-seq:
 *   to_link -> Link
 * 
 * Return a Link for the track.
 */
static VALUE cTrack_to_link(VALUE self)
{
  return mkLink(sp_link_create_from_track(DATA_PPTR(self, sp_track), 0));
}

/**
 * call-seq:
 *   starred? -> true or false
 * 
 * True if the track is starred.
 */
static VALUE cTrack_starred(VALUE self)
{
  return sp_track_is_starred(DATA_PPTR(self, sp_track)) ? Qtrue : Qfalse;
}

/**
 * call-seq:
 *   duration -> Fixnum
 * 
 * Track duration in milliseconds.
 */
static VALUE cTrack_duration(VALUE self)
{
  return INT2FIX(sp_track_duration(DATA_PPTR(self, sp_track)));
}

/**
 * call-seq:
 *   error -> String
 * 
 * Returns the error status for the Track.
 */
static VALUE cTrack_error(VALUE self)
{
  return rb_str_new2(sp_error_message(sp_track_error(DATA_PPTR(self, sp_track))));
}

/**
 * call-seq:
 *   popularity -> Fixnum
 * 
 * Track popularity in the range 0 - 100.
 */
static VALUE cTrack_popularity(VALUE self)
{
  return INT2FIX(sp_track_popularity(DATA_PPTR(self, sp_track)));
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * End track methods
 **/

/**
 * Allocates memory for a new User.
 */
static VALUE ciUser_alloc(VALUE self)
{
  sp_user **puser;
  return Data_Make_Struct(self, sp_user*, 0, -1, puser);
}

/**
 * call-seq:
 *   name(canonical = false) -> String
 * 
 * Retrieve the users’ display name (falls back to canonical name if 
 * display name is unavailable).
 */
static VALUE cUser_name(int argc, VALUE *argv, VALUE self)
{
  VALUE canonical = Qfalse;
  sp_user *user = DATA_PPTR(self, sp_user);
  
  rb_scan_args(argc, argv, "01", &canonical);

  return rb_str_new2(RTEST(canonical)
    ? sp_user_canonical_name(user)
    : sp_user_display_name(user)
  );
}

/**
 * call-seq:
 *   loaded? -> true or false
 *
 * True if user is loaded and display name is available.
 */
static VALUE cUser_loaded(VALUE self)
{
  return sp_user_is_loaded(DATA_PPTR(self, sp_user)) ? Qtrue : Qfalse;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * End user methods
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
  rb_define_method(cSession, "user", cSession_user, 0);
  
  // PlaylistContainer class
  cPlaylistContainer = rb_define_class_under(mHallon, "PlaylistContainer", rb_cObject);
  rb_define_alloc_func(cPlaylistContainer, ciPlaylistContainer_alloc);
  rb_define_method(cPlaylistContainer, "initialize", cPlaylistContainer_initialize, 1);
  rb_define_method(cPlaylistContainer, "length", cPlaylistContainer_length, 0);
  rb_define_method(cPlaylistContainer, "push", cPlaylistContainer_add, 1);
  rb_define_method(cPlaylistContainer, "at", cPlaylistContainer_at, 1);
  rb_define_method(cPlaylistContainer, "delete_at", cPlaylistContainer_delete_at, 1);
  
  // Playlist class
  cPlaylist = rb_define_class_under(mHallon, "Playlist", rb_cObject);
  rb_define_alloc_func(cPlaylist, ciPlaylist_alloc);
  rb_define_method(cPlaylist, "initialize", cPlaylist_initialize, 0);
  rb_define_method(cPlaylist, "name", cPlaylist_name, 0);
  rb_define_method(cPlaylist, "length", cPlaylist_length, 0);
  rb_define_method(cPlaylist, "loaded?", cPlaylist_loaded, 0);
  rb_define_method(cPlaylist, "to_link", cPlaylist_to_link, 0);
  rb_define_method(cPlaylist, "pending?", cPlaylist_pending, 0);
  rb_define_method(cPlaylist, "collaborative?", cPlaylist_collaborative, 0);
  rb_define_method(cPlaylist, "collaborative=", cPlaylist_set_collaborative, 1);
  rb_define_method(cPlaylist, "insert", cPlaylist_insert, -1);
  rb_define_method(cPlaylist, "at", cPlaylist_at, 1);
  rb_define_method(cPlaylist, "remove", cPlaylist_remove, 1);
  rb_define_method(cPlaylist, "name=", cPlaylist_set_name, 1);
  rb_define_method(cPlaylist, "owner", cPlaylist_owner, 0);
  
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
  rb_define_method(cTrack, "loaded?", cTrack_loaded, 0);
  rb_define_method(cTrack, "available?", cTrack_available, 0);
  rb_define_method(cTrack, "to_link", cTrack_to_link, 0);
  rb_define_method(cTrack, "starred?", cTrack_starred, 0);
  rb_define_method(cTrack, "duration", cTrack_duration, 0);
  rb_define_method(cTrack, "error", cTrack_error, 0);
  rb_define_method(cTrack, "popularity", cTrack_popularity, 0);
  
  // User class
  cUser = rb_define_class_under(mHallon, "User", rb_cObject);
  rb_define_alloc_func(cUser, ciUser_alloc);
  rb_define_method(cUser, "name", cUser_name, -1);
  rb_define_method(cUser, "loaded?", cUser_loaded, 0);
}