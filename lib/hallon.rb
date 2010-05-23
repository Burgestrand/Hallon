# Add extension to load path
$:.unshift File.expand_path('./../ext/', File.dirname(__FILE__))

require 'hallon'

# libspotify[https://developer.spotify.com/en/libspotify/overview/] bindings for Ruby!
module Hallon
  # Thrown by Hallon::Session on Spotify errors.
  class Error
  end
  
  # Main workhorse of Hallon. You must first initialize an instance to fly
  # to never-never land!
  class Session
    require 'singleton'
    include Singleton # Spotify APIv4
    
    def self.instance(*args) # :nodoc:
      if @__instance__ and args.length > 0
        raise ArgumentError, "session has already been initialized"
      end
      
      @__instance__ ||= new *args
    end
  end
end