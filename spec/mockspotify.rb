# coding: utf-8
require 'ffi'
require 'rbconfig'

module Spotify
  module Mock
    # @return [String] path to the libmockspotify C extension binary.
    def self.path
      File.expand_path('../mockspotify/libmockspotify.', __FILE__) << RbConfig::MAKEFILE_CONFIG['DLEXT']
    end

    # Overridden to always ffi_lib the mock path.
    def ffi_lib(*)
      super(Mock.path)
    end

    # Overriden to not throw an error on missing functions.
    def attach_function(name, *)
      super
    rescue FFI::NotFoundError => e
      define_singleton_method(name) do |*args|
        raise FFI::NotFoundError, "#{name} has not been defined"
      end
      warn "#{e.message}" if $VERBOSE
    end
  end

  class API
    extend FFI::Library
    extend Mock
  end

  require 'spotify'

  module Mock
    class PlaylistTrack < Spotify::Struct
      layout :track, :pointer,
             :create_time, :int,
             :creator, :pointer,
             :message, Spotify::NULString,
             :seen, :bool
    end

    class PlaylistContainerItem < Spotify::Struct
      layout :playlist, :pointer,
             :type, :playlist_type,
             :folder_name, Spotify::NULString,
             :folder_id, :uint64,
             :num_seen_tracks, :int,
             :seen_tracks, :array
    end
  end

  class API
    old_verbose, $VERBOSE = $VERBOSE, true

    # Some of these can accept null pointers, but our type protection ensures
    # that we never pass null values in place of spotify objects, so we work
    # around it by not using the real types. We still want to document the kind
    # used, however.
    typedef :pointer, :track
    typedef :pointer, :album
    typedef :pointer, :artist
    typedef :pointer, :playlist
    typedef :pointer, :user

    attach_function :mock_registry_find, [:string], :pointer
    attach_function :mock_registry_add, [:string, :pointer], :void
    attach_function :mock_registry_clean, [], :void

    attach_function :mock_session_create, [:pointer, :connectionstate, :int, OfflineSyncStatus, :int, :int, :playlist], Session
    attach_function :mock_user_create, [:string, :string, :bool], User
    attach_function :mock_track_create, [:string, :int, :array, :album, :int, :int, :int, :int, :error, :bool, :availability, :track_offline_status, :bool, :bool, :track, :bool, :bool], Track
    attach_function :mock_image_create, [ImageID, :imageformat, :size_t, :buffer_in, :error], Image
    attach_function :mock_artist_create, [:string, ImageID, :bool], Artist
    attach_function :mock_album_create, [:string, :artist, :int, ImageID, :albumtype, :bool, :bool], Album

    attach_function :mock_albumbrowse_create, [:error, :int, :album, :artist, :int, :array, :int, :array, :string, :albumbrowse_complete_cb, :userdata], AlbumBrowse
    attach_function :mock_artistbrowse_create, [:error, :int, :artist, :int, :array, :int, :array, :int, :array, :int, :array, :int, :array, :string, :artistbrowse_type, :artistbrowse_complete_cb, :userdata], ArtistBrowse
    attach_function :mock_toplistbrowse_create, [:error, :int, :int, :array, :int, :array, :int, :array], ToplistBrowse

    attach_function :mock_playlist_create, [:string, :bool, :user, :bool, :string, ImageID, :bool, :uint, Subscribers, :bool, :playlist_offline_status, :int, :int, :array], Playlist
    attach_function :mock_playlistcontainer_create, [:user, :bool, :int, :array, PlaylistContainerCallbacks, :userdata], PlaylistContainer
    attach_function :mock_search_create, [:error, :string, :string, :int, :int, :array, :int, :int, :array, :int, :int, :array, :int, :int, :array, :search_complete_cb, :userdata], Search
    attach_function :mock_subscribers, [:int, :array], Subscribers

    # mocked accessors
    attach_function :mock_playlist_get_autolink_tracks, [Playlist], :bool
    attach_function :mock_session_set_is_scrobbling_possible, [Session, :social_provider, :bool], :void

    $VERBOSE = old_verbose
  end
end
