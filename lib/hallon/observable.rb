# coding: utf-8
module Hallon
  # A module providing event capabilities to Hallon objects.
  #
  # @private
  module Observable
    # Defines a handler for the given event.
    #
    # @param [#to_sym] event name of event to handle
    # @return [Proc] the given block
    # @yield (*args) event handler block
    def on(event, &block)
      raise ArgumentError, "no block given" unless block
      raise NameError, "no such callback: #{event}" unless has_callback?(event)
      handlers[event.to_s] = block
    end

    # @param [#to_s] name
    # @return [Boolean] true if a callback with `name` exists
    def has_callback?(name)
      respond_to?("#{name}_callback", true)
    end

    # @yield [callback] attaches automatically after yielding
    # @yieldparam [Proc] callback
    # @yieldreturn [#attach]
    #
    # @param [#to_s] name
    # @return [Proc] callback method handle for given name.
    def callback_for(name)
      callback = method("#{name}_callback").to_proc
      yield(callback).attach(callback) if block_given?
      callback
    end

    # Run a given block, and once it exits restore all handlers
    # to the way they were before running the block.
    #
    # This allows you to temporarily use different handlers for
    # some events.
    def protecting_handlers
      old_handlers = handlers.dup
      yield
    ensure
      handlers.replace(old_handlers)
    end

    protected

    # @param [#to_s] name
    # @param [...] arguments
    # @return whatever the handler returns
    def trigger(name, *arguments, &block)
      name = name.to_s
      arguments << self
      handlers[name].call(*arguments, &block)
    end

    # @return [Hash<String, Proc>]
    def handlers
      @__handlers ||= Hash.new(proc {})
    end
  end
end
