Hallon’s Changelog
==================

[HEAD][]
------------------

__Added__

__Changed__

- Rewritten Enumerator system (Playlist#tracks, Search#albums et al) [676f7d1e]
- Search#{tracks,albums,artists}_total removed in favor of Search#{tracks,albums,artists}.total [d5c2e7aa]

__Fixed__

- Enumerators now check size before each iteration [4ec24969]

[v0.12.0][]
------------------

__Added__

- New system of handling callbacks (with documentation)
- Hallon::Queue (useful for music_delivery callback)
- PlaylistContainer::Folder#contents

__Changed__

- Rewrote the callback system (5f74ed8)
- Thread.abort_on_exception = true
- Upgraded to Spotify v10.3.0

__Fixed__

- Hallon::Error.maybe_raise(:is_loading) will not raise now
- UTF8 strings in applicable places for output/input
- Playlist#name= validation issue (allowing too long names)

[v0.11.0][]
------------------

__Added__

- Playlist#can_move?
- Base.from(pointer)

__Changed__

- Playlist#move no longer takes a dry_run parameter

__Fixed__

- Player#music_delivery callback ignoring consumed frames
- Session#wait_for minimum timeout time from 0 to 10 ms

[v0.10.1][] (actually v0.10.0)
------------------

__Added__

- Add PlaylistContainer::Folder#rename
- Add PlaylistContainer#insert_folder
- Add PlaylistContainer#move (do see #57)
- Add PlaylistContainer#remove
- Add ability to retrieve PlaylistContainer folders
- Make PlaylistContainer#add accept a spotify playlist URI
- Link.new now supports any #to_link’able object
- Playlist::Track#moved?
- PlaylistContainer callback support (to be changed, see #56)

__Fixed__

- A lot of random deadlocks (updated spotify gem dependency)

[v0.9.1][]
------------------

__Added__

- PlaylistContainer#size
- User#published
- PlaylistContainer#contents (only for playlists)
- PlaylistContainer#add (existing playlist, new playlist)

__Changed__

- Playlist#seen now moved to Playlist::Track#seen=

__Fixed__

- Album#cover null pointer issue (https://github.com/Burgestrand/Hallon/issues/53)
- Various possible null pointer bugs

[v0.9.0][]
------------------

- Upgraded to libspotify *v10*
- Improve documentation consistency
- Link.new now raises an error if there’s no session
- Minimal PlaylistContainer support (more to come next version)

__Added__

- Playlist subsystem support
- Toplist#request_duration
- AlbumBrowse#request_duration
- ArtistBrowse#request_duration
- ArtistBrowse.types
- Player#volume_normalization(?|=)
- Session.new accepting device_id/tracefile options
- Session#login!/relogin!/logout! convenience methods
- Session#starred: starred playlist for currently logged in user
- Session#inbox: inbox for currently logged in user
- Session.instance?
- Image.new(image_id_in_hex) support
- Link#to_uri
- User.new(canonical_username)
- User#post: posting tracks to other users’ inboxes
- User#starred: starred playlist of a given user
- Track#placeholder?
- Track#offline_status
- Track#unwrap
- type parameter to Artist#browse

__Fixed__

- Moved from using FFI::Pointers to Spotify::Pointers
- Spotify::Pointer garbage collection
- Link#valid? using exceptions for flow control
- Session#connection_rules= now raises an error when given invalid rule
- Search.radio now raises an error when given invalid genres

__Changed__

- Playlist::Track#seen= removed in favor of Playlist#seen(index, yesno)
- Object#error -> Object#status (AlbumBrowse, ArtistBrowse, Search, Toplist, User)
- Album#year renamed to Album#release_year
- Linkable.from_link/to_link and resulting #from_link are now private


[v0.8.0][]
------------------

__Added__

- Add example for listing track information in playlists
- Updated to (lib)Spotify v9
- Full Track subsystem support
- Full Album subsystem support
- Full AlbumBrowse subsystem support
- Full Artist subsystem support
- Full ArtistBrowse subsystem support
- Full Toplist subsystem support
- Full Search subsystem support
- Allow setting Session connection type/rules
- Session offline query methods (offline_time_left et al)
- Work-in-progress Player
- Add Session relogin support
- Add Enumerator
- Use libmockspotify for testing (spec/mockspotify)
- Add Hallon::Base class
- Add optional parameter to have Image#id return raw id
- Allow Image.new to accept an image id
- Add Hallon::API_BUILD

__Fixed__

- Improve speed of Session#wait_for for already-loaded cases
- Error.maybe_raise no longer errors out on timeout
- from_link now checks for null pointers
- No longer uses autotest as development dependency
- Cleaned up specs to use same mocks everywhere
- Make Hallon::URI match image URIs

__Broke__

- Ignore Ruby v1.8.x compatibility

[v0.3.0][]
------------------

- Don’t use bundler for :spec and :test rake tasks
- Add Error.table
- Add Track subsystem
- Fix spec:cov and spotify:coverage rake tasks

[v0.2.1][]
------------------

- Fix compatibility with v1.8

[v0.2.0][]
------------------

- Alias Session#process_events_on to Session#wait_until
- Have Error.maybe_raise return error code
- Use mockspotify gem (https://rubygems.org/gems/mockspotify) for testing

[v0.1.1][]
------------------

- Don’t show the README in the gem description.

[v0.1.0][]
------------------

Initial, first, release! This version is merely made to
have a starting point, a point of reference, for future
releases soon to come.

- Error subsystem is covered (`sp_error_message(error_code)`)
- Image subsystem is complete, however you can only create images
  from links at this moment.
- Session API is partial. Currently you can login, logout, retrieve
  the logged in user and query user relations.
- User API is complete, but you can only create users from your
  currently logged in user (through Session) or from links.

The API is still very young, and I expect a lot of changes to
happen to it, to make the asynchronous nature of libspotify
easier to handle.

[v0.1.0]: https://github.com/Burgestrand/Hallon/compare/5f2e118...v0.1.0
[v0.1.1]: https://github.com/Burgestrand/Hallon/compare/v0.1.0...v0.1.1
[v0.2.0]: https://github.com/Burgestrand/Hallon/compare/v0.1.1...v0.2.0
[v0.2.1]: https://github.com/Burgestrand/Hallon/compare/v0.2.0...v0.2.1
[v0.3.0]: https://github.com/Burgestrand/Hallon/compare/v0.2.1...v0.3.0
[v0.8.0]: https://github.com/Burgestrand/Hallon/compare/v0.3.0...v0.8.0
[v0.9.0]: https://github.com/Burgestrand/Hallon/compare/v0.8.0...v0.9.0
[v0.9.1]: https://github.com/Burgestrand/Hallon/compare/v0.9.0...v0.9.1
[v0.10.1]: https://github.com/Burgestrand/Hallon/compare/v0.9.1...v0.10.1
[v0.11.0]: https://github.com/Burgestrand/Hallon/compare/v0.10.1...v0.11.0
[v0.12.0]: https://github.com/Burgestrand/Hallon/compare/v0.11.0...v0.12.0
[HEAD]: https://github.com/Burgestrand/Hallon/compare/v0.12.0...HEAD
