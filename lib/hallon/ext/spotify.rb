# coding: utf-8

# Extensions to the Spotify gem.
#
# @see https://github.com/Burgestrand/libspotify-ruby
module Spotify

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
