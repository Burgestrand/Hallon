module Hallon
  # Wraps Spotify URIs in a class, giving access to methods performable on them.
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__link.html
  class Link
    # True if the given Spotify URI is valid (parsable by libspotify).
    # 
    # @param (see Hallon::Link#initialize)
    # @return [Boolean]
    def self.valid?(spotify_uri)
      !! new(spotify_uri)
    rescue ArgumentError
      false
    end
    
    # Parse the given Spotify URI into a Link.
    # 
    # @warn Unless you have a {Session} initialized, this will segfault!
    # @param [#to_s] uri
    # @raise [ArgumentError] link could not be parsed
    def initialize(uri)
      @pointer = Spotify::Pointer.new(Spotify::link_create_from_string(uri), :link)
      raise ArgumentError, "Could not parse Spotify URI" if @pointer.null?
    end
    
    # Get the Spotify URI this Link represents.
    # 
    # @param [Fixnum] length maximum length 
    # @return [String]
    def to_str(length = length)
      FFI::Buffer.alloc_out(length + 1) do |b|
        Spotify::link_as_string(@pointer, b, b.size)
        return b.get_string(0)
      end
    end
    
    # Link type as a symbol.
    # 
    # @return [Symbol]
    def type
      Spotify::link_type(@pointer)
    end
    
    # Spotify URI length.
    # 
    # @return [Fixnum]
    def length
      Spotify::link_as_string(@pointer, nil, 0)
    end
    
    # String representation of the given Link.
    # 
    # @return [String]
    def to_s
      "<#{self.class.name} #{to_str}>"
    end
  end
end