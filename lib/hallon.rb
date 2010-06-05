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
    
    def self.instance(*args)
      if @__instance__ and args.length > 0
        raise ArgumentError, "session has already been initialized"
      end

      @__instance__ ||= new *args
    end
  end
  
  # Contains the users playlists.
  class PlaylistContainer
    def size
      return length
    end
  end
  
  # Information about a given playlist.
  class Playlist
    def size
      return length
    end
  end
  
  class Link
    # Compares one Spotify URI with another — Link or String.
    def ==(other)
      return to_str == other.to_str
    end
  end
end