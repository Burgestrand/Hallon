# coding: utf-8
module Hallon
  # A module providing event capabilities to Hallon objects.
  #
  # @private
  module Observable
    # Defines a handler for the given event.
    #
    # @example defining a handler and triggering it
    #   on(:callback) do |message|
    #     puts message
    #   end
    #
    #   trigger(:callback, "Moo!") # => prints "Moo!"
    #
    # @example multiple events with one handler
    #   on(:a, :b, :c) do |name, *args|
    #     puts "#{name} called with: #{args.inspect}"
    #   end
    #
    #   trigger(:a) # => prints ":a called with: []"
    #   trigger(:b, :c) # => prints ":b called with: [:c]"
    #
    # @note when defining a handler for multiple events, the
    #       first argument passed to the handler is the name
    #       of the event that called it
    # @param [#to_sym] event name of event to handle
    # @yield (*args) event handler block
    def on(*events, &block)
      raise ArgumentError, "no block given" unless block
      wrap = events.length > 1
      events.map(&:to_sym).each do |event|
        block = proc { |*args| yield(event, *args) } if wrap
        __handlers[event] = [] unless __handlers.has_key?(event)
        __handlers[event] << block
      end
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
      deep_copy = __handlers.dup.clear
      __handlers.each do |k, v|
        deep_copy[k] = v.dup
      end
      yield
    ensure
      __handlers.replace deep_copy
    end

    private
      # Hash mapping events to handlers.
      #
      # @return [Hash]
      def __handlers
        @__handlers ||= Hash.new([])
      end
  end
end
