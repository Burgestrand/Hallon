require 'singleton'

module Hallon
  class Session
    # @return [String]
    attr_reader :application_key
    
    # @return [String]
    attr_reader :user_agent
    
    # @return [String]
    attr_reader :settings_path
    
    # @return [String]
    attr_reader :cache_path
    
    # @return [Thread]
    attr_reader :event_handler
    
    include Singleton
    
    # Allows you to create a Spotify session. Subsequent calls to this method
    # will return the previous instance, ignoring any passed arguments.
    #
    # @param (see Session#initialize)
    # @see Session#initialize
    # @see http://ruby-doc.org/core/classes/Singleton.html
    # @return [Session]
    def Session.instance(*args, &block)
      @__instance__ ||= new(*args, &block)
    end
    
    # True if currently logged in.
    # @see #state
    def logged_in?
      state == :logged_in
    end
    
    # True if logged out.
    # @see #state
    def logged_out?
      state == :logged_out
    end
    
    # True if session has been disconnected.
    # @see #state
    def disconnected?
      state == :disconnected
    end
  end
end