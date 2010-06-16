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
    include Enumerable
    
    # Alias for #length
    def size
      return length
    end
  end
  
  # Playlists are created from the PlaylistContainer.
  class Playlist
    include Enumerable
    
    private_class_method :new
    
    # Yield each Track in the playlist to the passed block.
    def each(&block)
      acc = Array.new
      
      length.times do |i|
        obj = self.at(i)
        obj = yield obj if block_given?
        acc.push obj
      end
      
      return acc
    end
    
    # Alias for #insert! length, Track...
    def push(*tracks)
      insert length, *tracks
    end
    
    # Alias for #push
    def <<(*tracks)
      push *tracks
    end
    
    # Alias for #length
    def size
      return length
    end
  end
  
  # Object for acting Spotify URIs.
  class Link
    # Return the ID for this link
    def id
      return to_str.split(':').last
    end
    
    # Compares one Spotify URI with another — Link or String.
    def ==(other)
      return to_str == other.to_str
    end
  end
  
  # A class for acting on Tracks. You create a Track by using Link#to_obj.
  class Track
    private_class_method :new
  end
end