module Hallon
  class << Error
    # Raise a {Hallon::Error} error if, and only if, the given errno is not 0.
    # If so, the raised exception will correspond to the error number.
    # 
    # @param [Fixnum] errno
    # @return [nil]
    def maybe_raise(errno)
      return if errno == 0
      raise Hallon::Error, Hallon::Error.explain(errno) + "(#{errno})"
    end
  end
end