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
    include Linkable
    include Loadable

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
    # @param [String, Link, Spotify::Artist] link
    def initialize(link)
      @pointer = to_pointer(link, Spotify::Artist)
    end

    # @return [String] name of the artist.
    def name
      Spotify.artist_name(pointer)
    end

    # @return [Boolean] true if the artist is loaded.
    def loaded?
      Spotify.artist_is_loaded(pointer)
    end

    # @see portrait_link
    # @param [Symbol] size (see {Image.sizes})
    # @return [Image, nil] artist portrait as an Image.
    def portrait(size = :normal)
      portrait = Spotify.artist_portrait(pointer, size)
      Image.from(portrait)
    end

    # @see portrait
    # @param [Symbol] size (see {Image.sizes})
    # @return [Link, nil] artist portrait as a Link.
    def portrait_link(size = :normal)
      portrait = Spotify.link_create_from_artist_portrait(pointer, size)
      Link.from(portrait)
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
