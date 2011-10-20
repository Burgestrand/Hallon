module Hallon
  # Artists in Hallon are the people behind the songs. Methods
  # are defined for retrieving their names and loaded status.
  #
  # To retrieve more information about an artist, you can browse
  # it. This will give access to more detailed data such as bio,
  # portraits and more. Hallon does not support this as of yet,
  # but you can use the underlying Spotify API for this, just like
  # we have for {Album}s.
  #
  # Both Albums and Tracks can have more than one artist.
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__artist.html
  class Artist < Base
    extend Linkable

    from_link :as_artist
    to_link   :from_artist

    # Construct an artist given a link.
    #
    # @param [String, Link, FFI::Pointer] link
    def initialize(link)
      @pointer = to_pointer(link, :artist)
    end

    # Retrieve Artist name. Empty string if Artist is not loaded.
    #
    # @return [String]
    def name
      Spotify.artist_name(@pointer)
    end

    # True if the Artist is loaded.
    #
    # @return [Boolean]
    def loaded?
      Spotify.artist_is_loaded(@pointer)
    end

    # @param [Boolean] as_image true if you want it as an Image
    # @return [Image, Link, nil] artist portrait, or the link to it, or nil
    def portrait(as_image = true)
      portrait = Spotify.link_create_from_artist_portrait!(pointer)
      unless portrait.null?
        klass = as_image ? Image : Link
        klass.new(portrait)
      end
    end

    # Browse the Artist, giving you the ability to explore its’
    # portraits, biography and more.
    #
    # @return [ArtistBrowse] an artist browsing object
    def browse
      ArtistBrowse.new(pointer)
    end
  end
end
