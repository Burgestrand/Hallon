module Hallon
  # The Hallon::Scrobbler is responsible for controlling play scrobbling.
  #
  # You can construct the scrobbler with different providers to control
  # scrobbling for each one individually. The scrobbler includes a list
  # of social providers, methods to adjust the scrobbling of libspotify,
  # and methods to retrieve the current scrobbling state.
  class Scrobbler
    # @return [Array<Symbol>] list of available scrobbling providers
    def self.providers
      Spotify.enum_type(:social_provider).symbols
    end

    # @return [Symbol] social provider
    attr_reader :provider

    # Initialize the scrobbler with a social provider.
    #
    # @note it appears that in libspotify v12.1.56, the only valid provider
    #       is :facebook — all other providers return errors
    #
    # @raise [ArgumentError] if the given provider is invalid
    # @param [Symbol] provider
    def initialize(provider)
      provider_to_i = Spotify.enum_value!(provider, "social provider")
      @provider = Spotify.enum_type(:social_provider)[provider_to_i]
    end

    # @note if this returns false, it usually means libspotify either has
    #       no scrobbling credentials, or the user has disallowed spotify
    #       from scrobbling to the given provider
    #
    # @note this method only works for the :facebook provider; for all other
    #       providers it will always return true
    #
    # @return [Boolean] true if scrobbling is possible
    def possible?
      case provider
      when :spotify, :lastfm
        # libspotify v12.1.56 has a bug with all providers except for :facebook
        # where the return value is always :invalid_indata; however, the devs
        # also mentioned the function would always return true for all other
        # providers anyway
        true
      else
        FFI::Buffer.alloc_out(:bool) do |buffer|
          Spotify.session_is_scrobbling_possible!(session.pointer, provider, buffer)
          return ! buffer.read_uchar.zero?
        end
      end
    end

    protected

    # @return [Hallon::Session]
    def session
      Session.instance
    end
  end
end
