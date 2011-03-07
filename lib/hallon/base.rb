module Hallon
  # All Spotify objects share some common behavior, and this class is
  # here to accomodate for that. It makes sure the internal C struct
  # is allocated properly, and that the event handler is properly
  # set to the object inheriting from Hallon::Base.
  # 
  # @note this class is for internal use by Hallon only
  # @private
  class Base
    # A string representation of this object: its’ class name.
    # 
    # @return [String]
    def to_s
      self.class.name
    end
    
    private
      # Defines a handler for the given event.
      # 
      # @param [#to_sym] event name of event to handle
      # @yield (*args) event handler block
      # @see #initialize
      def on(event, &block)
        singleton_class.instance_eval do
          define_method(:"on_#{event}", &block)
        end
      end
  end
end