# coding: utf-8
module Hallon
  # Thrown by Hallon on libspotify errors.
  #
  # Hallon::Error inherits two methods from Spotify::Error:
  #
  # - Hallon::Error.explain(error) - from a Spotify error, create a descriptive string of it
  # - Hallon::Error.disambiguate(error) - return the tuple of [code, symbol] of a given Spotify error
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__error.html
  class Error < Spotify::Error
    class << self
      # Hash of error (Symbol) to code (Integer).
      #
      # @return [Hash<Symbol, Integer>]
      def table
        Spotify.enum_type(:error).to_hash
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

        raise self, explain(error)
      end
    end
  end
end
