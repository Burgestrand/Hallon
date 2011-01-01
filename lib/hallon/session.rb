# coding: utf-8
require 'singleton'

module Hallon
  class Session
    # The options Hallon used at {Session#initialize}
    # 
    # @return [Hash]
    attr_reader :options
    
    # Application key used at {Session#initialize}
    #
    # @return [String]
    attr_reader :appkey
    
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
    
    # Merge the given hash with default options for Session#initialize
    #
    # @private
    # @param [Hash, nil] options
    # @return [Hash]
    def merge_defaults(options)
      options ||= {}
      {
        :user_agent => "Hallon",
        :settings_path => ".",
        :cache_path => ""
      }.merge(options)
    end
  
    # Spawns a new thread that constantly reads from the `queue` and dispatches
    # events to the {Session}.
    #
    # To exit the thread using events, throw a `:shuriken` in a handler. You
    # can fire your own events using {Session#fire!}.
    #
    # @private
    # @note This is called automatically by Session#initialize.
    # @param [Queue] queue
    # @param [Class] handler (default: {Hallon::Handler})
    # @return [Thread]
    def spawn_consumer(queue, handler)
      handler = handler.new(self)
      @event_consumer = Thread.new do
        catch :shuriken do
          loop do
            event = queue.shift
          
            begin
              handler.public_send(*event)
            rescue StandardError => e
              warn "<Event #{event.inspect} raised #{e.inspect}> #{e.message}"
            end
          end
        end
      end
    end
  end
end