# coding: utf-8

# Extensions to the Spotify gem.
#
# @see https://github.com/Burgestrand/libspotify-ruby
module Spotify
  # Extensions to SessionConfig, allowing more sensible configuration names.
  SessionConfig.class_eval do
    [:cache_location, :settings_location, :user_agent, :device_id, :proxy, :proxy_username, :proxy_password, :tracefile].each do |field|
      method = field.to_s.gsub('location', 'path')

      define_method(:"#{method}") { self[field].read_string }
      define_method(:"#{method}=") do |string|
        string &&= FFI::MemoryPointer.from_string(string)
        self[field] = string
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

  # Makes it easier binding callbacks safely to callback structs.
  #
  # @see add
  # @see remove
  module CallbackStruct
    # Before assigning [member]=(callback), inspect the arity of
    # said callback and raise an ArgumentError if they don‘t match.
    #
    # @raise ArgumentError if the arity of the given callback does not match the member
    def []=(member, callback)
      unless callback.arity < 0 or callback.arity == arity_of(member)
        raise ArgumentError, "#{member} callback takes #{arity_of(member)} arguments, was #{callback.arity}"
      else
        super
      end
    end

    protected

    # @param [Symbol] member
    # @return [Integer] arity of the given callback member
    def arity_of(member)
      fn = layout[member].type
      fn.param_types.size
    end
  end

  SessionCallbacks.instance_eval do
    include CallbackStruct
  end

  PlaylistCallbacks.instance_eval do
    include CallbackStruct
  end

  PlaylistContainerCallbacks.instance_eval do
    include CallbackStruct
  end
end
