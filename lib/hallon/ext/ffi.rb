module FFI
  class Pointer
    type = FFI.find_type(:size_t)
    type, _ = FFI::TypeDefs.find do |(name, t)|
      method_defined? "read_#{name}" if t == type
    end

    alias_method :read_size_t, "read_#{type}" if type
  end
end
