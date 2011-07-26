module Hallon
  # All objects in Hallon are mere representations of Spotify objects.
  # Hallon::Base covers basic functionality shared by all of these.
  class Base
    # Underlying FFI pointer.
    #
    # @protected
    # @return [FFI::Pointer]
    attr_reader :pointer
    protected   :pointer

    # True if both objects represent the *same* object.
    #
    # @param [Object] other
    # @return [Boolean]
    def ==(other)
      pointer == other.pointer
    rescue NoMethodError
      super
    end
  end
end
