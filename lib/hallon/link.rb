# coding: utf-8
module Hallon
  # Wraps Spotify URIs in a class, giving access to methods performable on them.
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__link.html
  class Link
    include Comparable

    # True if the given Spotify URI is valid (parsable by libspotify).
    #
    # @param (see Hallon::Link#initialize)
    # @return [Boolean]
    def self.valid?(spotify_uri)
      !! new(spotify_uri)
    rescue ArgumentError
      false
    end

    # Overloaded to short-circuit when given a Link.
    #
    # @return [Hallon::Link]
    def self.new(uri)
      uri.is_a?(Link) ? uri : super
    end

    # Parse the given Spotify URI into a Link.
    #
    # @note Unless you have a {Session} initialized, this will segfault!
    # @param [#to_s] uri
    # @raise [ArgumentError] link could not be parsed
    def initialize(uri)
      if (link = uri).respond_to? :to_str
        link = Spotify::link_create_from_string(link.to_str)
      end

      @pointer = Spotify::Pointer.new(link, :link)

      raise ArgumentError, "#{uri} is not a valid Spotify link" if @pointer.null?
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

    # Get the Spotify URI this Link represents.
    #
    # @see #length
    # @param [Fixnum] length truncate to this size
    # @return [String]
    def to_str(length = length)
      FFI::Buffer.alloc_out(length + 1) do |b|
        Spotify::link_as_string(@pointer, b, b.size)
        return b.get_string(0)
      end
    end

    # Retrieve the full Spotify HTTP URL for this Link.
    #
    # @return [String]
    def to_url
      "http://open.spotify.com/%s" % to_str[8..-1].gsub(':', '/')
    end

    # Compare this Link to another object
    #
    # @param [#to_str] other
    # @return [Integer]
    def <=>(other)
      to_str <=> String.try_convert(other)
    end

    # String representation of the given Link.
    #
    # @return [String]
    def to_s
      "<#{self.class.name} #{to_str}>"
    end

    # Retrieve the underlying pointer.
    #
    # @param [Symbol] expected_type if given, makes sure the link is of this type
    # @return [FFI::Pointer]
    # @raise ArgumentError if `type` is given and does not match link {#type}
    def pointer(expected_type = nil)
      unless type == expected_type
        raise ArgumentError, "expected #{expected_type} link, but it is of type #{type}"
      end if expected_type
      @pointer
    end
  end
end
