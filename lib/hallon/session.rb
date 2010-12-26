require 'singleton'
require 'hallon/session/callbacks'

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
      status == :logged_in
    end
    
    # True if logged out.
    # @see #state
    def logged_out?
      status == :logged_out
    end
    
    # True if session has been disconnected.
    # @see #state
    def disconnected?
      status == :disconnected
    end
    
    private
      def spawn_consumer(queue)
        @event_consumer = Thread.new(self) do |session|
          loop do
            event = queue.shift
            puts "(Consumer) Handling: #{event.inspect}"
            session.send(*event)
          end
        end
      end
  end
end