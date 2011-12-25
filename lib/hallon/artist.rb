# coding: utf-8
module Hallon
  # Artists in Hallon are the people behind the songs. Methods
  # are defined for retrieving their names and loaded status.
  #
  # To retrieve more information about an artist, you can {#browse}
  # it. This will give access to more detailed data such as bio,
  # portraits and more.
  #
  # Both Albums and Tracks can have more than one artist.
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__artist.html
  class Artist < Base
    extend Linkable

    from_link :as_artist
    to_link   :from_artist

    # Construct an Artist from a link.
    #
    # @example from a spotify URI
    #
    #   artist = Hallon::Artist.new("spotify:artist:6uSKeCyQEhvPC2NODgiqFE")
    #
    # @example from a link
    #
    #   link = Hallon::Link.new("spotify:artist:6uSKeCyQEhvPC2NODgiqFE")
    #   artist = Hallon::Artist.new(link)
    #
    # @param [String, Link, FFI::Pointer] link
    def initialize(link)
      @pointer = to_pointer(link, :artist)
    end

    # @return [String] name of the artist.
    def name
      Spotify.artist_name(pointer)
    end

    # @return [Boolean] true if the artist is loaded.
    def loaded?
      Spotify.artist_is_loaded(pointer)
    end

    # Retrieve artist portrait as an {Image} or a {Link}.
    #
    # @param [Boolean] as_image true if you want it as an Image
    # @return [Image, Link, nil] artist portrait, the link to it, or nil.
    def portrait(as_image = true)
      if as_image
        portrait = Spotify.artist_portrait(pointer)
        Image.from(portrait)
      else
        portrait = Spotify.link_create_from_artist_portrait!(pointer)
        Link.from(portrait)
      end
    end

    # Browse the Artist, giving you the ability to explore its’
    # portraits, biography and more.
    #
    # @param [Symbol] type browsing type (see {ArtistBrowse.types})
    # @return [ArtistBrowse] an artist browsing object
    def browse(type = :full)
      ArtistBrowse.new(pointer, type)
    end
  end
end
