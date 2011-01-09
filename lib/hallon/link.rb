module Hallon
  # Wraps Spotify URIs in a class, giving access to methods performable on them.
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__link.html
  class Link
    class << self
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
    
    # String representation of the given Link.
    # 
    # @return [String]
    def to_s
      "<#{self.class.name} #{to_str}>"
    end
  end
end