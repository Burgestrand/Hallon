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
  end
end