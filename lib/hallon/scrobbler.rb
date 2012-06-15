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

    # Sets the scrobbling credentials.
    #
    # @example setting username and password
    #   scrobbling.credentials = 'kim', 'password'
    #
    # @param [Array<Username, Password>] credentials
    def credentials=(credentials)
      username, password = Array(credentials)
      Spotify.session_set_social_credentials!(session.pointer, provider, username, password)
    end

    # Enables or disables the local scrobbling setting.
    #
    # @param [Boolean] scrobble true if you want scrobbling to be enabled
    def enabled=(scrobble)
      state = scrobble ? :local_enabled : :local_disabled
      Spotify.session_set_scrobbling!(session.pointer, provider, state)
    end

    # @return [Boolean] true if scrobbling (global or local) is enabled.
    def enabled?
      FFI::Buffer.alloc_out(:int) do |buffer|
        Spotify.session_is_scrobbling(session.pointer, provider, buffer)
        state = read_state(buffer.read_uint)
        return !! (state =~ /enabled/)
      end
    end

    # Sets the local scrobbling state to the global state.
    #
    # @return [Scrobbler]
    def reset
      tap { Spotify.session_set_scrobbling!(session.pointer, provider, :use_global_setting) }
    end

    protected

    # Convert an integer state to an actual state symbol.
    #
    # @param [Integer] state
    # @return [Symbol] state as a symbol
    def read_state(state)
      Spotify.enum_type(:scrobbling_state)[state]
    end

    # @return [Hallon::Session]
    def session
      Session.instance
    end
  end
end
