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
      define_singleton_method(name) do
        raise FFI::NotFoundError, "#{name} has not been defined"
      end
      warn "#{e.message}" if $VERBOSE
    end
  end

  extend FFI::Library
  extend Mock
  require 'spotify'

  module Mock
    def self.find_type(*args, &block)
      Spotify.find_type(*args, &block)
    end

    class PlaylistTrack < FFI::Struct
      layout :track, :track,
             :create_time, :int,
             :creator, :user,
             :message, :pointer,
             :seen, :bool
    end

    class PlaylistContainerItem < FFI::Struct
      layout :playlist, :playlist,
             :type, :playlist_type,
             :folder_name, :pointer,
             :folder_id, :uint64,
             :num_seen_tracks, :int,
             :seen_tracks, :pointer
    end
  end

  old_verbose, $VERBOSE = $VERBOSE, true

  def self.attach_mock_function(name, cname, params, returns, options = {})
    attach_function(name, cname, params, returns, options)
    define_singleton_method("#{name}!") do |*args|
      Spotify::Pointer.new(send(name, *args), returns, false)
    end
  end

  attach_function :registry_find, [:string], :pointer
  attach_function :registry_add, [:string, :pointer], :void
  attach_function :registry_clean, [], :void

  attach_function :mock_session, :mocksp_session_create, [:pointer, :connectionstate, :int, Spotify::OfflineSyncStatus, :int, :int, :playlist], :session
  attach_mock_function :mock_user, :mocksp_user_create, [:string, :string, :bool], :user
  attach_mock_function :mock_track, :mocksp_track_create, [:string, :int, :array, :album, :int, :int, :int, :int, :error, :bool, :availability, :track_offline_status, :bool, :bool, :track, :bool, :bool], :track
  attach_mock_function :mock_image, :mocksp_image_create, [:image_id, :imageformat, :size_t, :buffer_in, :error], :image
  attach_mock_function :mock_artist, :mocksp_artist_create, [:string, :image_id, :bool], :artist
  attach_mock_function :mock_album, :mocksp_album_create, [:string, :artist, :int, :image_id, :albumtype, :bool, :bool], :album

  attach_function :mock_albumbrowse, :mocksp_albumbrowse_create, [:error, :int, :album, :artist, :int, :array, :int, :array, :string, :albumbrowse_complete_cb, :pointer], :albumbrowse
  attach_function :mock_artistbrowse, :mocksp_artistbrowse_create, [:error, :int, :artist, :int, :array, :int, :array, :int, :array, :int, :array, :int, :array, :string, :artistbrowse_type, :artistbrowse_complete_cb, :pointer], :artistbrowse
  attach_function :mock_toplistbrowse, :mocksp_toplistbrowse_create, [:error, :int, :int, :array, :int, :array, :int, :array], :toplistbrowse

  attach_mock_function :mock_playlist, :mocksp_playlist_create, [:string, :bool, :user, :bool, :string, :image_id, :bool, :uint, Spotify::Subscribers, :bool, :playlist_offline_status, :int, :int, :array], :playlist
  attach_mock_function :mock_playlistcontainer, :mocksp_playlistcontainer_create, [:user, :bool, :int, :array, PlaylistContainerCallbacks, :userdata], :playlistcontainer
  attach_function :mock_search, :mocksp_search_create, [:error, :string, :string, :int, :int, :array, :int, :int, :array, :int, :int, :array, :int, :int, :array, :search_complete_cb, :pointer], :search
  attach_function :mock_subscribers, :mocksp_subscribers, [:int, :array], Spotify::Subscribers

  # mocked accessors
  attach_function :mocksp_playlist_get_autolink_tracks, [:playlist], :bool

  $VERBOSE = old_verbose
end
