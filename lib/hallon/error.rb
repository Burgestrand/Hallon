# coding: utf-8
module Hallon
  # Thrown by Hallon on libspotify errors.
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__error.html
  class Error < RuntimeError
    class << self
      # Given a number or a symbol, find both the symbol and the error
      # number it represents.
      #
      # @param [Symbol, Fixnum]
      # @return [[Fixnum, Symbol]]
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

      # Raise an {Error} with the given errno, unless it is `0` or `:ok`.
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
