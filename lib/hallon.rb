# Add extension to load path
$:.unshift File.expand_path('./../ext/', File.dirname(__FILE__))

require 'hallon'

module Hallon
  class Session
    require 'singleton'
    include Singleton # Spotify APIv4
    
    def self.instance(*args)
      if @__instance__ and args.length > 0
        raise ArgumentError, "session has already been initialized"
      end
      
      @__instance__ ||= new *args
    end
  end
end