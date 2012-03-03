# coding: utf-8
module Hallon
  # Wraps Spotify URIs in a class, giving access to methods performable on them.
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__link.html
  class Link < Base
    # True if the given Spotify URI is valid (parsable by libspotify).
    #
    # @param [#to_s] spotify_uri
    # @return [Boolean]
    def self.valid?(spotify_uri)
      if spotify_uri.is_a?(Link)
        return true
      elsif spotify_uri.to_s["\x00"] # image ids
        return false
      end

      link = Spotify.link_create_from_string!(spotify_uri.to_s)
      not link.null?
    end

    # Parse the given Spotify URI into a Link.
    #
    # @note You must initialize a Session before you call this method.
    # @param [#to_str] uri
    # @raise [ArgumentError] link could not be parsed
    def initialize(uri)
      # if no session instance exists, libspotify segfaults, so assert that we have one
      unless Session.instance?
        raise "Link.new requires an existing Session instance"
      end

      # we support any #to_link’able object
      if uri.respond_to?(:to_link)
        uri = uri.to_link.pointer
      end

      @pointer = to_pointer(uri, :link) do
        Spotify.link_create_from_string!(uri.to_str)
      end
    end

    # @return [Symbol] link type as a symbol (e.g. `:playlist`).
    def type
      Spotify.link_type(pointer)
    end

    # @return [Fixnum] spotify URI length.
    def length
      Spotify.link_as_string(pointer, nil, 0)
    end

    # @see #length
    # @param [Fixnum] length truncate to this size
    # @return [String] spotify URI representation of this Link.
    def to_str(length = length)
      FFI::Buffer.alloc_out(length + 1) do |b|
        Spotify.link_as_string(pointer, b, b.size)
        return b.get_string(0).force_encoding("UTF-8")
      end
    end

    alias_method :to_uri, :to_str

    # @return [String] full Spotify HTTP URL.
    def to_url
      "http://open.spotify.com/%s" % to_str[8..-1].gsub(':', '/')
    end

    # Compare the Link to other. If other is a Link, also compare
    # their `to_str` if necessary.
    #
    # @param [Object] other
    # @return [Boolean]
    def ==(other)
      super or if other.is_a?(Link)
        to_str == other.to_str
      end
    end

    # @return [String] string representation of the Link.
    def to_s
      "<#{self.class.name} #{to_str}>"
    end

    # @param [Symbol] expected_type if given, makes sure the link is of this type
    # @return [Spotify::Pointer] the underlying Spotify::Pointer.
    # @raise ArgumentError if `type` is given and does not match link {#type}
    def pointer(expected_type = nil)
      unless type == expected_type or (expected_type == :playlist and type == :starred)
        raise ArgumentError, "expected #{expected_type} link, but it is of type #{type}"
      end if expected_type
      super()
    end
  end
end
