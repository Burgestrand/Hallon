# coding: utf-8
require 'ref'

module Hallon
  # A module providing event capabilities to Hallon objects.
  #
  # @private
  module Observable
    # This module is responsible for creating methods for registering
    # callbacks. It expects a certain protocol to already available.
    module ClassMethods
      # When extended it’ll call #initialize_observable to set-up `other`.
      def self.extended(other)
        other.send(:initialize_observable)
      end

      # @return [Method, Struct] callbacks to attach to this object
      attr_reader :callbacks

      # Subscribe to callbacks for a given pointer.
      #
      # @param [Object] object
      # @param [FFI::Pointer] pointer
      def subscribe(object, pointer)
        key = pointer.address
        ref = Ref::WeakReference.new(object)

        @lock.synchronize do
          if @subscribers_rev[ref.referenced_object_id]
            raise ArgumentError, "already subscribed to callbacks"
          end

          @subscribers[key] ||= {} # use a hash for fast reverse lookups
          @subscribers[key][ref.referenced_object_id] = ref
          @subscribers_rev[ref.referenced_object_id] = key
        end

        ObjectSpace.define_finalizer(object, @unsubscriber)
      end

      # Retrieve all subscribers for a given pointer.
      #
      # @param [FFI::Pointer] pointer
      def subscribers_for(pointer)
        key = pointer.address

        @lock.synchronize do
          @subscribers.fetch(key, {}).values.map(&:object).compact
        end
      end

      protected

      # Run when ClassMethods are extended.
      #
      # It sets up the callbacks and all book-keeping required to keep
      # track of all subscribers properly.
      def initialize_observable
        @callbacks = initialize_callbacks

        @lock = Ref::SafeMonitor.new
        @subscribers = {}
        @subscribers_rev = {}
        @unsubscriber = proc do |object_id|
          @lock.synchronize do
            if key = @subscribers_rev.delete(object_id)
              @subscribers[key].delete(object_id)
              @subscribers.delete(key) if @subscribers[key].empty?
            end
          end
        end
      end

      # @param [#to_s] name
      # @return [Method]
      def callback_for(name)
        method("#{name}_callback")
      end

      # Scans through the list of subscribers, trying to find any
      # subscriber attached to this pointer. For each subscriber,
      # trigger the appropriate event.
      #
      # @param [FFI::Pointer] pointer
      # @param [Symbol] event
      # @param […] arguments
      # @return whatever the (last) handler returned
      def trigger(pointer, event, *arguments)
        subscribers_for(pointer).inject(nil) do |_, subscriber|
          # trigger is protected, inconvenient but symbolic
          subscriber.send(:trigger, event, *arguments)
        end
      end
    end

    # Will extend `other` with {ClassMethods}.
    def self.included(other)
      other.extend(ClassMethods)
    end

    # Defines a handler for the given event.
    #
    # @param [#to_s] event name of event to handle
    # @return [Proc] the previous handler
    # @yield (*args) event handler block
    def on(event, &block)
      raise ArgumentError, "no block given" unless block
      raise NameError, "no such callback: #{event}" unless has_callback?(event)
      handlers[event.to_s].tap do
        handlers[event.to_s] = block
      end
    end

    # Wait for the given callbacks to fire until the block returns true
    #
    # @note Given block will be called once instantly without parameters.
    # @note If no events happen for 0.25 seconds, the block will be called without parameters.
    # @param [Symbol, ...] events list of events to wait for
    # @yield [Symbol, *args] name of the event that fired, and its’ arguments
    # @return whatever the block returns
    def wait_for(*events)
      channel = SizedQueue.new(10) # sized just to be safe

      old_handlers = events.each_with_object({}) do |event, hash|
        hash[event] = on(event) do |*args|
          channel << [event, *args]
          hash[event].call(*args)
        end
      end

      old_notify = session.on(:notify_main_thread) do
        channel << :notify
      end

      if result = yield
        return result
      end

      loop do
        begin
          timeout = [session.process_events.fdiv(1000), 2].min # scope to two seconds
          timeout = timeout + 0.010 # minimum of ten miliseconds timeout
          params = Timeout::timeout(timeout) { channel.pop }
          redo if params == :notify
        rescue Timeout::Error
          params = nil
        end

        if result = yield(*params)
          return result
        end
      end
    ensure
      old_handlers.each_pair do |event, handler|
        on(event, &handler)
      end unless old_handlers.nil?
      session.on(:notify_main_thread, &old_notify) unless old_notify.nil?
    end


    # @param [#to_s] name
    # @return [Boolean] true if a callback with `name` exists.
    def has_callback?(name)
      self.class.respond_to?("#{name}_callback", true)
    end

    # Run a given block, and once it exits restore all handlers
    # to the way they were before running the block.
    #
    # This allows you to temporarily use different handlers for
    # some events.
    #
    # @yield
    def protecting_handlers
      old_handlers = handlers.dup
      yield
    ensure
      handlers.replace(old_handlers)
    end

    protected

    # Register this object as interested in callbacks.
    #
    # @yield [callback]
    # @yieldparam [Method, Struct] callback (always the same object)
    # @return whatever the block returns
    def subscribe_for_callbacks
      yield(self.class.callbacks).tap do
        self.class.subscribe(self, pointer) unless pointer.null?
      end
    end

    # @param [#to_s] name
    # @param [...] arguments
    # @return whatever the handler returns
    def trigger(name, *arguments, &block)
      if handler = handlers[name.to_s]
        handler.call(*arguments, &block)
      end
    end

    # @return [Hash<String, Proc>]
    def handlers
      @__handlers ||= Hash.new(proc {})
    end
  end
end
