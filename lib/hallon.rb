# require extension file
require File.expand_path('./../../ext/hallon', __FILE__)
require 'singleton'

# libspotify[https://developer.spotify.com/en/libspotify/overview/] bindings for Ruby!
module Hallon
  # Thrown by Hallon::Session on Spotify errors.
  class Error < StandardError
  end
  
  # Main workhorse of Hallon!
  class Session
    include Singleton # Spotify APIv4
    
    # Acessor for ::new
    def self.instance(*args)
      if @__instance__ and args.length > 0
        raise ArgumentError, "session has already been initialized"
      end

      @__instance__ ||= new *args
    end
  end
  
  # Contains the users playlists.
  class PlaylistContainer
    # Alias for #length
    def size
      return length
    end
  end
  
  # Playlists are created from the PlaylistContainer.
  class Playlist
    private_class_method :new
    
    # Alias for #length
    def size
      return length
    end
  end
  
  # Object for acting Spotify URIs.
  class Link
    # Compares one Spotify URI with another — Link or String.
    def ==(other)
      return to_str == other.to_str
    end
  end
end