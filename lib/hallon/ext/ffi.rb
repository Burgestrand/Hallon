# Custom extensions to the FFI gem.
#
# @see https://github.com/ffi/ffi
module FFI
  # FFI::Pointer is the underlying class used to read
  # and write data to pointers. For more information
  # see the FFI gem.
  class Pointer
    type, _ = begin
      type = FFI.find_type(:size_t)
      FFI::TypeDefs.find do |(name, t)|
        method_defined? "read_#{name}" if t == type
      end
    end

    unless type.nil?
      # Read N `size_t` from the start of the pointer.
      #
      # @param [Integer] count how many to read
      # @return a type of appropriate size
      define_method(:read_size_t) do |*args|
        public_send("read_#{type}", *args)
      end
    end
  end
end
