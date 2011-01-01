module Hallon
  class << Error
    # Raise a Hallon::Error error if, and only if, the given value is not 0. If
    # so, the raised exception will correspond to the error number.
    # 
    # @param [Fixnum] value
    # @return nil
    def maybe_raise(value)
      return if value == 0
      raise Hallon::Error, Hallon::Error.explain(value) + "(#{value})"
    end
  end
end