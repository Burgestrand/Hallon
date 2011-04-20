module Hallon
  # An internal module which allows easy definition of callback handlers
  # using {#on}.
  # 
  # @example
  #   on(:callback) do
  #     # handle it
  #   end
  # 
  # @private
  module Base
    # Defines a handler for the given event.
    # 
    # @param [#to_s] event name of event to handle
    # @yield (*args) event handler block
    # @see #initialize
    def on(event, &block)
      define_singleton_method(:"on_#{event}", &block)
    end
    
    # Run the given block, protecting all previous event handlers.
    # 
    # @yield
    # @return whatever the given block returns
    def protecting_handlers
      on_method = method(:on)
      overridden_callbacks = {}
      
      define_singleton_method(on_method.name) do |event, &block|
        handler_name = :"on_#{event}"
        overridden_callbacks[handler_name] = method(handler_name)
        on_method.call(event, &block)
      end
      
      yield
    ensure
      define_singleton_method(on_method.name, &on_method)
      overridden_callbacks.each_pair do |event, handler|
        define_singleton_method(event, handler)
      end
    end
  end
end