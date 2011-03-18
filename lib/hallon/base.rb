module Hallon
  module Base
    private
      # Defines a handler for the given event.
      # 
      # @param [#to_s] event name of event to handle
      # @yield (*args) event handler block
      # @see #initialize
      def on(event, &block)
        singleton_class.instance_eval do
          define_method(:"on_#{event}", &block)
        end
      end
  end
end