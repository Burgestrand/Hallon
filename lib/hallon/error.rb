# coding: utf-8
module Hallon
  # Thrown by Hallon on libspotify errors.
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__error.html
  class Error < RuntimeError
    class << self
      # Hash of error (Symbol) to code (Integer).
      #
      # @return [Hash<Symbol, Integer>]
      def table
        Spotify.enum_type(:error).to_hash
      end

      # Given a number or a symbol, find both the symbol and the error
      # number it represents.
      #
      # @param [Symbol, Fixnum] error
      # @return [[Fixnum, Symbol]] (error code, error symbol)
      def disambiguate(error)
        @enum ||= Spotify.enum_type(:error)

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
      # @example
      #   Hallon::Error.explain(:ok) # => "No error"
      #
      # @param [Fixnum, Symbol]
      # @return [String]
      def explain(error)
        Spotify.error_message disambiguate(error)[0]
      end

      # Raise an {Error} with the given errno, unless it is `nil`, `:timeout`, `0` or `:ok`.
      #
      # @example
      #
      #   Hallon::Error.maybe_raise(error, ignore: :is_loading)
      #
      # @param [Fixnum, Symbol] error
      # @param [Hash] options
      # @option options [Array] :ignore ([]) other values to ignore of error
      # @return [nil]
      def maybe_raise(x, options = {})
        ignore = [nil, :timeout] + Array(options[:ignore])
        return nil if ignore.include?(x)

        error, symbol = disambiguate(x)
        return symbol if symbol == :ok

        message = []
        message << "[#{symbol.to_s.upcase}]"
        message << explain(error)
        message << "(#{error})"
        raise Hallon::Error, message.join(' ')
      end
    end
  end
end
