module Hallon
  class Error < RuntimeError
    class << self
      # Given a number or a symbol, return the pair [Fixnum, Symbol] for
      # which this error represents.
      # 
      # @param [Symbol, Fixnum]
      # @return a pair (Fixnum, Symbol)
      def disambiguate(error)
        @enum ||= Spotify::enum_type(:error)
        
        if error.is_a? Symbol
          error = @enum[symbol = error]
        else
          symbol = @enum[error]
        end
        
        if error.nil? || symbol.nil?
          [-1, nil]
        else
          [error, symbol]
        end
      end
      
      # Explain a Spotify error with a string message.
      # 
      # @param [Fixnum, Symbol]
      # @return [String]
      def explain(error)
        Spotify::error_message disambiguate(error)[0]
      end

      # Raise a {Hallon::Error} error if, and only if, the given errno is not 0.
      # If so, the raised exception will correspond to the error number.
      # 
      # @param [Fixnum, Symbol] error
      # @return [nil]
      def maybe_raise(error)
        error, symbol = disambiguate(error)
        
        unless symbol == :ok
          message = []
          message << "[#{symbol.upcase}]"
          message << explain(error)
          message << "(#{error})"
          raise Hallon::Error, message.join(' ')
        end
      end
    end
  end
end