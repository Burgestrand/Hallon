require 'monitor'
require 'forwardable'

module Hallon
  # A module providing event capabilities to Hallon objects.
  #
  # @private
  module Base
    # Required for maintaining thread-safety around #monitor.
    IMonitor = Monitor.new

    # Defines a handler for the given event.
    #
    # @example
    #   o = Object.new
    #   o.instance_eval { include Hallon::Base }
    #
    #   on(:callback) do |*args|
    #     # handle it
    #   end
    #
    #   o.on_callback("Moo!")
    #
    # @param [#to_sym] event name of event to handle
    # @yield (*args) event handler block
    # @see #initialize
    def on(event)
      event = event.to_sym
      __handlers[event] = [] unless __handlers.has_key?(event)
      __handlers[event] << Proc.new
    end

    # Trigger a handler for a given event.
    #
    # @param [#to_sym] event
    # @param [Object, ...] params given to each handler
    def trigger(event, *params, &block)
      catch :return do
        return_value = nil
        __handlers[event.to_sym].each do |handler|
          return_value = handler.call(*params, &block)
        end
        return_value
      end
    end

    # Run the given block, protecting all previous event handlers.
    #
    # @example
    #   o = Object.new
    #   o.instance_eval { include Hallon::Base }
    #   o.on(:method) { "outside" }
    #
    #   puts o.on_method # => "outside"
    #   o.protecting_handlers do
    #     o.on(:method) { "inside" }
    #     puts o.on_method # => "inside"
    #   end
    #   puts o.on_method # => "outside"
    #
    # @yield
    # @return whatever the given block returns
    def protecting_handlers
      deep_copy = Hash[__handlers.map { |(k, v)| [k, v.dup] }]
      yield
    ensure
      __handlers.replace deep_copy
    end

    # We delegate Monitor methods using this.
    extend Forwardable

    # Conceive a new condition variable bound to this object.
    #
    # @see Monitor#new_cond
    # @return [Monitor::ConditionVariable]
    def new_cond
      monitor.new_cond
    end

    def_delegators :monitor, :synchronize

    private
      # Retrieve our Monitor instance, creating a new one if necessary.
      #
      # @note This function is thread-safe.
      # @return [Monitor]
      def monitor
        IMonitor.synchronize { @monitor ||= Monitor.new }
      end

      # Hash mapping events to handlers.
      #
      # @return [Hash]
      def __handlers
        @__handlers ||= Hash.new([])
      end
  end
end
