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
      # Spawns a new thread that constantly reads from the `queue` and dispatches
      # events to the {Session}.
      #
      # To exit the thread using events, throw a `:shuriken` in a handler. You
      # can fire your own events using {Session#fire!}.
      #
      # @note This is called automatically by Session#initialize.
      # @param [Queue] queue
      # @param [#new] handler (default: {Session::Callbacks})
      # @return [Thread]
      def spawn_consumer(queue, handler = Callbacks.new(self))
        @event_consumer = Thread.new(handler) do |callbacks|
          catch :shuriken do
            loop do
              event = *queue.shift

              begin
                begin
                  callbacks.public_send(*event) # First try user-given handler
                rescue NoMethodError
                  public_send(*event) # Fall back to Session as an event handler
                end
              rescue StandardError => e
                $stderr.puts "[error] <Event #{event.inspect}> #{e.inspect}"
              end
            end
          end
        end
      end
  end
end