module Hallon
  # All Spotify objects share some common behavior, and this class is
  # here to accomodate for that. It makes sure the internal C struct
  # is allocated properly, and that the event handler is properly
  # set to the object inheriting from Hallon::Base.
  # 
  # @note this class is for internal use by Hallon only
  # @private
  class Base
    # Defines a handler for the given event.
    # 
    # @param [#to_sym] event
    # @yield
    # @return Method or Proc
    def on(event, &block)
      singleton_class.instance_eval do
        define_method(:"on_#{event}", &block)
      end
    end
    
    def to_s
      self.class.name
    end
  end
end