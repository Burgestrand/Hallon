# coding: utf-8

# Extensions to the Spotify gem.
#
# @see https://github.com/Burgestrand/libspotify-ruby
module Spotify
  # Wraps the function `function` so that it always returns
  # a Spotify::Pointer with correct refcount. Functions that
  # contain the word `create` are assumed to start out with
  # a refcount of `+1`.
  #
  # @param [#to_s] function
  # @param [#to_s] return_type
  # @raise [NoMethodError] if `function` is not defined
  # @see Spotify::Pointer
  def self.wrap_function(function, return_type)
    define_singleton_method("#{function}!") do |*args|
      pointer = public_send(function, *args)
      Spotify::Pointer.new(pointer, return_type, function !~ /create/)
    end
  end

  # @macro [attach] wrap_function
  #   Same as {Spotify}.`$1`, but wraps result in a {Spotify::Pointer}.
  #
  #   @method $1!
  #   @return [Spotify::Pointer<$2>]
  #   @see #$1
  wrap_function :session_user, :user
  wrap_function :session_playlistcontainer, :playlistcontainer
  wrap_function :session_inbox_create, :playlist
  wrap_function :session_starred_create, :playlist
  wrap_function :session_starred_for_user_create, :playlist
  wrap_function :session_publishedcontainer_for_user_create, :playlistcontainer
  wrap_function :session_friend, :user

  wrap_function :track_artist, :artist
  wrap_function :track_album, :album
  wrap_function :localtrack_create, :track

  wrap_function :album_artist, :artist

  wrap_function :albumbrowse_create, :albumbrowse
  wrap_function :albumbrowse_album, :album
  wrap_function :albumbrowse_artist, :artist
  wrap_function :albumbrowse_track, :track

  wrap_function :artistbrowse_create, :artistbrowse
  wrap_function :artistbrowse_artist, :artist
  wrap_function :artistbrowse_track, :track
  wrap_function :artistbrowse_album, :album
  wrap_function :artistbrowse_similar_artist, :artist

  wrap_function :image_create, :image
  wrap_function :image_create_from_link, :image

  wrap_function :link_as_track, :track
  wrap_function :link_as_track_and_offset, :track
  wrap_function :link_as_album, :album
  wrap_function :link_as_artist, :artist
  wrap_function :link_as_user, :user

  wrap_function :link_create_from_string, :link
  wrap_function :link_create_from_track, :link
  wrap_function :link_create_from_album, :link
  wrap_function :link_create_from_artist, :link
  wrap_function :link_create_from_search, :link
  wrap_function :link_create_from_playlist, :link
  wrap_function :link_create_from_artist_portrait, :link
  wrap_function :link_create_from_artistbrowse_portrait, :link
  wrap_function :link_create_from_album_cover, :link
  wrap_function :link_create_from_image, :link
  wrap_function :link_create_from_user, :link

  wrap_function :search_create, :search
  wrap_function :radio_search_create, :search
  wrap_function :search_track, :track
  wrap_function :search_album, :album
  wrap_function :search_artist, :artist

  wrap_function :playlist_track, :track
  wrap_function :playlist_track_creator, :user
  wrap_function :playlist_owner, :user
  wrap_function :playlist_create, :playlist

  wrap_function :playlistcontainer_playlist, :playlist
  wrap_function :playlistcontainer_add_new_playlist, :playlist
  wrap_function :playlistcontainer_add_playlist, :playlist
  wrap_function :playlistcontainer_owner, :user

  wrap_function :toplistbrowse_create, :toplistbrowse
  wrap_function :toplistbrowse_artist, :artist
  wrap_function :toplistbrowse_album, :album
  wrap_function :toplistbrowse_track, :track

  wrap_function :inbox_post_tracks, :inbox

  # The Pointer is a kind of AutoPointer specially tailored for Spotify
  # objects, that releases the raw pointer on GC.
  class Pointer < FFI::AutoPointer
    # @param [FFI::Pointer] pointer
    # @param [#to_s] type session, link, etc
    # @param [Boolean] add_ref
    # @return [FFI::AutoPointer]
    def initialize(pointer, type, add_ref)
      super pointer, releaser_for(type)
      Spotify.send(:"#{type}_add_ref", pointer) if add_ref
    end

    # Create a proc that will accept a pointer of a given type and
    # release it with the correct function if it’s not null.
    #
    # @param [Symbol]
    # @return [Proc]
    def releaser_for(type)
      lambda do |pointer|
        unless pointer.null?
          $stdout.puts "Spotify::#{type}_release(#{pointer})" if $DEBUG
          Spotify.send(:"#{type}_release", pointer)
        end
      end
    end
  end

  # Extensions to SessionConfig, allowing more sensible configuration names.
  SessionConfig.class_eval do
    [:cache_location, :settings_location, :user_agent].each do |field|
      method = field.to_s.gsub('location', 'path')

      define_method(:"#{method}") { self[field].read_string }
      define_method(:"#{method}=") do |string|
        self[field] = FFI::MemoryPointer.from_string(string)
      end
    end

    # @note Also sets application_key_size.
    # @param [#to_s]
    def application_key=(appkey)
      self[:application_key] = FFI::MemoryPointer.from_string(appkey)
      self[:application_key_size] = appkey.bytesize
    end

    # Allows setting compress_playlists using a boolean.
    #
    # @param [Boolean]
    # @return [Boolean]
    def compress_playlists=(bool)
      self[:compress_playlists] = !! bool
    end

    # Allows setting initially_unload_playlists using a boolean.
    #
    # @note Set to the inverse of the requested value.
    # @param [Boolean]
    # @return [Boolean]
    def load_playlists=(bool)
      self[:initially_unload_playlists] = ! bool
    end

    # Allows setting dont_save_metadata_for_playlists using a boolean.
    #
    # @note Set to the inverse of the requested value.
    # @param [Boolean]
    # @return [Boolean]
    def cache_playlist_metadata=(bool)
      self[:dont_save_metadata_for_playlists] = ! bool
    end
  end

  # Extensions to SessionCallbacks, making it easier to define callbacks.
  SessionCallbacks.class_eval do
    # Assigns the callbacks to call the given target; the callback
    # procs are stored in the `storage` parameter. **Make sure the
    # storage does not get garbage collected as long as these callbacks
    # are needed!**
    #
    # @param [Object] target
    # @param [#&#91;&#93;&#61;] storage
    def initialize(target, storage)
      members.each do |member|
        callback = lambda { |ptr, *args| target.trigger(member, *args) }
        self[member] = storage[member] = callback
      end
    end
  end

  PlaylistCallbacks.class_eval do
    # Assigns the callbacks to call the given target; the callback
    # procs are stored in the `storage` parameter. **Make sure the
    # storage does not get garbage collected as long as these callbacks
    # are needed!**
    #
    # @param [Object] target
    # @param [#&#91;&#93;&#61;] storage
    def initialize(target, storage)
      members.each do |member|
        callback = lambda { |ptr, *args| target.trigger(member, *args[0...-1]) }
        self[member] = storage[member] = callback
      end
    end
  end
end
