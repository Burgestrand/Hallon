require 'thread'

module Hallon
  # `libspotify` sometimes calls back to C-functions on certain events. Most of
  # the library operations are asynchronous, and fire callbacks when they are
  # finished. This means we must be able to handle the callbacks from Ruby.
  module Events
    # Spawns the Event Dispatcher. This is one of two threads responsible for
    # handling events fired by `libspotify`. The other one is in
    # `ext/hallon/events.c`, responsible for sending events to this thread.
    # 
    # @param [Queue] queue
    # @return [Thread]
    def self.spawn_dispatcher(queue)
      Thread.new do
        loop do
          handler, event, *args = queue.pop
          event = :"on_#{event}"
          
          begin
            handler.public_send(event, *args)
          rescue => e
            warn "#{handler}##{event}(#{args.join(', ')}) => #{e.message}"
          end if handler.respond_to?(event)
        end
      end
    end

    # Spawns both the Taskmaster and the Dispatcher.
    # 
    # @return [Array<Thread, Thread>] (taskmaster, dispatcher)
    def self.spawn_handlers
      queue = Queue.new
      [spawn_taskmaster(queue), spawn_dispatcher(queue)]
    end
  end
end