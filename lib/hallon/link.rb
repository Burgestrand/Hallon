module Hallon
  class << Link
    # True if the given Spotify URI is valid (parsable by libspotify).
    # 
    # @param (see Hallon::Link#initialize)
    # @return [Boolean]
    def valid?(spotify_uri)
      begin
        !! new(spotify_uri)
      rescue ArgumentError
        false
      end
    end
  end
end