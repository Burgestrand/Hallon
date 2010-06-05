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
    alias :_add :add
    def add(name)
      raise ArgumentError, "playlist name must be less than 256 characters" unless name.length < 256
      raise ArgumentError, "playlist must have at least one non-space character" unless name.match "[^ ]"
      _add(name)
    end
  end
  
  # Information about a given playlist.
  class Playlist
  end
  
  # Links
  class Link
    def ==(other)
      to_str == other.to_str
    end
  end
end