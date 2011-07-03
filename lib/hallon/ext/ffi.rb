module FFI
  class Pointer
    # Document-method: read_size_t
    #
    # Read N `size_t` from the start of the pointer.
    #
    # @param [Integer] count how many to read
    # @return a type of appropriate size

    type = FFI.find_type(:size_t)
    type, _ = FFI::TypeDefs.find do |(name, t)|
      method_defined? "read_#{name}" if t == type
    end

    alias_method :read_size_t, "read_#{type}" if type
  end
end
