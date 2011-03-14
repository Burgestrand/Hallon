# coding: utf-8
require 'singleton'

module Hallon
  class Session < Base
    # The options Hallon used at {Session#initialize}.
    # 
    # @see Session#merge_defaults
    # @return [Hash]
    attr_reader :options
    
    # Application key used at {Session#initialize}
    #
    # @return [String]
    attr_reader :appkey
    
    # libspotify only allows one session per process.
    include Singleton
    
    # Allows you to create a Spotify session. Subsequent calls to this method
    # will return the previous instance, ignoring any passed arguments.
    #
    # @param (see Session#initialize)
    # @see Session#initialize
    # @return [Session]
    def Session.instance(*args, &block)
      @__instance__ ||= new(*args, &block)
    end
    
    # True if currently logged in.
    # @see #status
    def logged_in?
      status == :logged_in
    end
    
    # True if logged out.
    # @see #status
    def logged_out?
      status == :logged_out
    end
    
    # True if session has been disconnected.
    # @see #status
    def disconnected?
      status == :disconnected
    end
    
    # Executed on `notify_main_thread` callback from libspotify.
    def on_notify_main_thread
      process_events
    end
    
    private
      # Merge the given hash with default options for {#initialize}.
      #
      # @note This is called automatically by {#initialize}.
      # @return [Hash]
      def merge_defaults(options)
        options = options || {}        
        {
          :user_agent => "Hallon",
          :settings_path => "tmp",
          :cache_path => "",
          
          :load_playlists => true,
          :compress_playlists => true,
          :cache_playlist_metadata => true
        }.merge(options)
      end
      
      # Spawns the Event Dispatcher.
      # 
      # This is one of two threads responsible for handling events fired
      # by `libspotify`. The other one is in `ext/hallon/callbacks.c`,
      # responsible for sending events to this thread.
      # 
      # Events are received by reading from the given queue; each item
      # in the queue is expected to be an array containing *at least*
      # two items: an object to handle the event, and the event name.
      # Any following items will be considered arguments to the handler.
      # 
      # The event name is prefixed with “on_” and then dispatched to
      # the handler: `handler.on_#{method}(*args)`
      # 
      # @param [Queue] queue used to read incoming events from
      # @return [Thread]
      def spawn_dispatcher(queue)
        Thread.new do
          loop do
            handler, method, *args = queue.pop
            method = :"on_#{method}"

            begin
              handler.public_send(method, *args)
            rescue => e
              warn "#{handler}##{method}(#{args.join(', ')}) => #{e.inspect}"
            end if handler.respond_to?(method)
          end
        end
      end
      
      # Spawns both the Taskmaster (callbacks.c) and the Dispatcher.
      # 
      # libspotify calls out to C functions when events occur, but
      # unfortunately this is done in an internal libspotify thread.
      # This means we are unable to call ruby functions directly in the
      # callbacks, and must find a way to bring the events and their
      # data into Ruby; the taskmaster and the dispatcher is how.
      # 
      # - libspotify is an event producer for the taskmaster
      # - the taskmaster is an event producer for the dispatcher
      # - the dispatcher executes the correct handler for each event
      # 
      # @return [Array<Thread, Thread>] (taskmaster, dispatcher)
      def spawn_handlers
        queue = Queue.new
        [spawn_taskmaster(queue), spawn_dispatcher(queue)]
      end
  end
end