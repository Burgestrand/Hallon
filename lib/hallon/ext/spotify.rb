# coding: utf-8

# Extensions to the Spotify gem.
# 
# @see https://github.com/Burgestrand/libspotify-ruby
module Spotify
  extend FFI::Library
  ffi_lib ['libspotify', '/Library/Frameworks/libspotify.framework/libspotify']
  
  # The Pointer is a kind of AutoPointer specially tailored for Spotify
  # objects. It will automatically release the inner pointer with the
  # proper function, based on the given type to #initialize.
  class Pointer < FFI::AutoPointer
    # Initialize the Spotify::Pointer
    # 
    # @param [FFI::Pointer] ptr
    # @param [Symbol] type session, link, etc
    # @return [FFI::AutoPointer]
    def initialize(ptr, type)
      super ptr, releaser_for(@type = type)
    end
    
    # Create a proc that will accept a pointer of a given type and
    # release it with the correct function if it’s not null.
    # 
    # @param [Symbol]
    # @return [Proc]
    def releaser_for(type)
      lambda do |ptr|
        unless ptr.null?
          $stdout.puts "Spotify::#{type}_release(#{ptr})" if Hallon::debug
          Spotify::send(:"#{type}_release", ptr)
        end
      end
    end
  end
  
  # Extensions to SessionCallbacks, making it easier to define callbacks.
  class SessionCallbacks < FFI::Struct
    # Assigns the callbacks to call the given target; the callback
    # procs are stored in the `storage` parameter. **Make sure the
    # storage does not get garbage collected as long as these callbacks
    # are needed!**
    # 
    # @param [Object] target
    # @param [#&#91;&#93;&#61;] storage
    def initialize(target, storage)
      members.each do |member|
        callback = :"on_#{member}"
        self[member] = storage[member] = lambda do |ptr, *args|
          target.public_send(callback, *args) if target.respond_to? callback
        end
      end
    end
  end
  
  # Extensions to SessionConfig, allowing more sensible configuration names.
  class SessionConfig < FFI::Struct
    [:cache_location, :settings_location, :application_key, :user_agent].each do |field|
      method = field.to_s.gsub('location', 'path')
      define_method(:"#{method}") { self[field].get_string(0) }
      define_method(:"#{method}=") do |string|
        self[field] = FFI::MemoryPointer.from_string(string)
      end
    end
    
    # Also sets application_key_size.
    # 
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
      self[:compress_playlists] = bool ? 1 : 0
    end
    
    # Allows setting initially_unload_playlists using a boolean.
    # 
    # @note Set to the inverse of the requested value.
    # @param [Boolean]
    # @return [Boolean]
    def load_playlists=(bool)
      self[:initially_unload_playlists] = ! bool ? 1 : 0
    end
    
    # Allows setting dont_save_metadata_for_playlists using a boolean.
    # 
    # @note Set to the inverse of the requested value.
    # @param [Boolean]
    # @return [Boolean]
    def cache_playlist_metadata=(bool)
      self[:dont_save_metadata_for_playlists] = ! bool ? 1 : 0
    end
  end
end