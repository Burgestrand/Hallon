require 'thread'

module Hallon
  # `libspotify` sometimes calls back to C-functions on certain events. Most of
  # the library operations are asynchronous, and fire callbacks when they are
  # finished. This means we must be able to handle the callbacks from Ruby.
  module Events
    require 'hallon/events/session'
    
    module ClassMethods
      # Defines a handler for the given event.
      # 
      # @param [#to_sym] event
      # @yield
      # @return Method or Proc
      def on(evt)
        define_method(evt.to_sym, &Proc.new)
      end
    end
    
    module InstanceMethods
      # Retrieve the subject associated with this handler (Session, Playlist, etc)
      # 
      # @return [Object]
      attr_accessor :subject

      # Associates the Handler with the given subject.
      # 
      # @see #subject
      # @param [Object]
      def initialize(subject)
        self.subject = subject
      end
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
    
    # Build a handler given either a class, module and/or block.
    #
    # @private
    # @see Hallon::Events
    # @param [Class<Hallon::Events>, Module, nil] handler
    # @param [Block, nil] block
    # @return [Hallon::Events]
    def self.build_handler(subject, handler = nil, &block)
      klass = if handler.is_a?(Class)
        raise ArgumentError, "must provide nil, module, or subclass of Hallon::Events" unless Hallon::Events >= handler
        handler
      else
        unless handler.is_a?(Module)
          handler = const_get(subject.class.name.split("::").last, false)
        end

        Class.new do
          include Hallon::Events
          include handler
        end
      end
      
      klass.module_eval(&block) if block_given?
      klass.new(subject)
    end
    
    # Spawns the Event Dispatcher. This is one of two threads responsible for
    # handling events fired by `libspotify`. The other one is in
    # `ext/hallon/events.c`, responsible for sending events to this thread.
    # 
    # @param [Queue] queue
    # @return [Thread]
    def self.spawn_dispatcher(queue)
      Thread.new do
        Thread.abort_on_exception = true

        loop do
          handler, args = queue.pop
          handler.public_send(*args)
        end
      end
    end

    # Spawns both the Taskmaster and the Dispatcher.
    # 
    # @return [taskmaster, dispatcher] (two threads)
    def self.spawn_handlers
      queue = Queue.new
      [spawn_taskmaster(queue), spawn_dispatcher(queue)]
    end
    
    private
      # Since I cannot use the `rb_funcall_passing_block` API, I use a proxy to
      # maintain the #build_handler API.
      # 
      # @param (see #build_handler)
      def self.proxy_build_handler(subject, handler, block)
        build_handler(subject, handler, &block)
      end
  end
end