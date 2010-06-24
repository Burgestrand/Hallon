# libspotify API coverage
This is a list of functions from `libspotify` that I’ve used, which does not necessarily reflect how much of `libspotify` I am using.

I have used 42 functions out of 146 functions in Hallon.

## Error Handling (1/1)
* ✔ sp\_error\_message

## Session handling (8/12)
* ✔ sp\_session\_init (Session::instance)
* ✔ sp\_session\_login (Session#login)
* ✔ sp\_session\_user
* ✔ sp\_session\_logout (Session#logout)
* ✔ sp\_session\_connectionstate (Session#logged\_in?)
* ✔ sp\_session\_userdata (internally: callback\_notify)
* ✔ sp\_session\_process\_events (internally: callback\_notify)
* sp\_session\_player\_load
* sp\_session\_player\_seek
* sp\_session\_player\_play
* sp\_session\_player\_unload
* ✔ sp\_session\_playlistcontainer
* sp\_session\_starred\_create
* sp\_session\_preferred\_bitrate

## Links (Spotify URIs) (7/14)
* ✔ sp\_link\_create\_from\_string (Link#new)
* ✔ sp\_link\_create\_from\_track (Track#to\_link)
* sp\_link\_create\_from\_album
* sp\_link\_create\_from\_artist
* sp\_link\_create\_from\_search
* ✔ sp\_link\_create\_from\_playlist (Playlist#to\_link)
* ✔ sp\_link\_as\_string (Link#to\_str)
* ✔ sp\_link\_type (Link#type)
* ✔ sp\_link\_as\_track (Link#to\_obj)
* sp\_link\_as\_track\_and\_offset
* sp\_link\_as\_album
* sp\_link\_as\_artist
* sp\_link\_add\_ref 
* ✔ sp\_link\_release (internally: ciLink\_free)

## Track subsystem (5/15)
* ✔ sp\_track\_is\_loaded (Track#loaded?)
* sp\_track\_error
* ✔ sp\_track\_is\_available (Track#available?)
* sp\_track\_is\_starred
* sp\_track\_set\_starred
* sp\_track\_num\_artists
* sp\_track\_artist
* sp\_track\_album
* ✔ sp\_track\_name (Track#name)
* sp\_track\_duration
* sp\_track\_popularity
* sp\_track\_disc
* sp\_track\_index
* ✔ sp\_track\_add\_ref (Track#initialize)
* ✔ sp\_track\_release (internally: ciTrack\_free)

## Album subsystem (0/9)
* sp\_album\_is\_loaded
* sp\_album\_is\_available
* sp\_album\_artist
* sp\_album\_cover
* sp\_album\_name
* sp\_album\_year
* sp\_album\_type
* sp\_album\_add\_ref
* sp\_album\_release

## Artist subsystem (0/4)
* sp\_artist\_name
* sp\_artist\_is\_loaded
* sp\_artist\_add\_ref
* sp\_artist\_release

## Album browsing (0/12)
* sp\_albumbrowse\_create
* sp\_albumbrowse\_is\_loaded
* sp\_albumbrowse\_error
* sp\_albumbrowse\_album
* sp\_albumbrowse\_artist
* sp\_albumbrowse\_num\_copyrights
* sp\_albumbrowse\_copyright
* sp\_albumbrowse\_num\_tracks
* sp\_albumbrowse\_track
* sp\_albumbrowse\_review
* sp\_albumbrowse\_add\_ref
* sp\_albumbrowse\_release

## Artist browsing (0/15)
* sp\_artistbrowse\_create
* sp\_artistbrowse\_is\_loaded
* sp\_artistbrowse\_error
* sp\_artistbrowse\_artist
* sp\_artistbrowse\_num\_portraits
* sp\_artistbrowse\_portrait
* sp\_artistbrowse\_num\_tracks
* sp\_artistbrowse\_track
* sp\_artistbrowse\_num\_albums
* sp\_artistbrowse\_album
* sp\_artistbrowse\_num\_similar\_artists
* sp\_artistbrowse\_similar\_artist
* sp\_artistbrowse\_biography
* sp\_artistbrowse\_add\_ref
* sp\_artistbrowse\_release

## Image handling (0/10)
* sp\_image\_create
* sp\_image\_add\_load\_callback
* sp\_image\_remove\_load\_callback
* sp\_image\_is\_loaded
* sp\_image\_error
* sp\_image\_format
* sp\_image\_data
* sp\_image\_image\_id
* sp\_image\_add\_ref
* sp\_image\_release

## Search subsystem (0/15)
* sp\_search\_create
* sp\_radio\_search\_create
* sp\_search\_is\_loaded
* sp\_search\_error
* sp\_search\_num\_tracks
* sp\_search\_track
* sp\_search\_num\_albums
* sp\_search\_album
* sp\_search\_num\_artists
* sp\_search\_artist
* sp\_search\_query
* sp\_search\_did\_you\_mean
* sp\_search\_total\_tracks
* sp\_search\_add\_ref
* sp\_search\_release

## Playlist subsystem (18/25)
* ✔ sp\_playlist\_is\_loaded (Playlist#loaded?)
* ✔ sp\_playlist\_add\_callbacks (Playlist#initialize)
* sp\_playlist\_remove\_callbacks
* ✔ sp\_playlist\_num\_tracks (Playlist#length)
* ✔ sp\_playlist\_track (Playlist#at)
* ✔ sp\_playlist\_name (Playlist#name)
* sp\_playlist\_rename
* sp\_playlist\_owner
* ✔ sp\_playlist\_is\_collaborative (Playlist#collaborative?)
* ✔ sp\_playlist\_set\_collaborative (Playlist#collaborative=)
* ✔ sp\_playlist\_has\_pending\_changes (Playlist#pending?)
* ✔ sp\_playlist\_add\_tracks (Playlist#insert)
* ✔ sp\_playlist\_remove\_tracks (Playlist#remove)
* sp\_playlist\_reorder\_tracks
* ✔ sp\_playlist\_create (Link#to\_obj)
* ✔ sp\_playlist\_add\_ref (Playlist#initialize)
* ✔ sp\_playlist\_release (internally: ciPlaylist\_free)
* ✔ sp\_playlistcontainer\_add\_callbacks (PlaylistContainer#initialize)
* sp\_playlistcontainer\_remove\_callbacks
* ✔ sp\_playlistcontainer\_num\_playlists (Playlist#length)
* ✔ sp\_playlistcontainer\_playlist (PlaylistContainer#at)
* ✔ sp\_playlistcontainer\_add\_new\_playlist (PlaylistContainer#add)
* sp\_playlistcontainer\_add\_playlist
* ✔ sp\_playlistcontainer\_remove\_playlist (PlaylistContainer#delete_at)
* sp\_playlistcontainer\_move\_playlist

## User handling (3/3)
* ✔ sp\_user\_canonical\_name
* ✔ sp\_user\_display\_name
* ✔ sp\_user\_is\_loaded

## Toplist handling (0/11)
* sp\_toplistbrowse\_create
* sp\_toplistbrowse\_is\_loaded
* sp\_toplistbrowse\_error
* sp\_toplistbrowse\_add\_ref
* sp\_toplistbrowse\_release
* sp\_toplistbrowse\_num\_artists
* sp\_toplistbrowse\_artist
* sp\_toplistbrowse\_num\_albums
* sp\_toplistbrowse\_album
* sp\_toplistbrowse\_num\_tracks
* sp\_toplistbrowse\_track