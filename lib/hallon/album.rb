# coding: utf-8
module Hallon
  # Albums are non-detailed metadata about actual music albums.
  #
  # To retrieve copyrights, album review and tracks you need to browse
  # the album. You do this by calling {Album#browse} to retrieve an
  # {AlbumBrowse} instance.
  #
  # It does still allow you to query some metadata information, such as
  # its’ {#name}, {#release_year}, {#type}, {#artist}, {#cover}…
  #
  # @note Pretty much all methods require the album to be {Album#loaded?}
  #       to return meaningful results.
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__album.html
  class Album < Base
    # @example
    #
    #   Hallon::Album.types # => [:album, :single, :compilation, :unknown]
    #
    # @return [Array<Symbol>] an array of different kinds of albums (compilations, singles, …)
    def self.types
      Spotify.enum_type(:albumtype).symbols
    end

    include Linkable
    include Loadable

    to_link   :from_album

    from_link :as_album

    # Construct an Album from a link.
    #
    # @example from a spotify URI
    #
    #   album = Hallon::Album.new("spotify:album:6TECAywzyJGh0kwxfeBgGc")
    #
    # @example from a link
    #
    #   link = Hallon::Link.new("spotify:album:6TECAywzyJGh0kwxfeBgGc")
    #   album = Hallon::Album.new(link)
    #
    # @param [String, Link, Spotify::Album] link
    def initialize(link)
      @pointer = to_pointer(link, Spotify::Album)
    end

    # @return [String] name of the album.
    def name
      Spotify.album_name(pointer)
    end

    # @return [Integer] release year of the album.
    def release_year
      Spotify.album_year(pointer)
    end

    # @see Album.types
    # @return [Symbol] album type.
    def type
      Spotify.album_type(pointer)
    end

    # @return [Boolean] true if the album is available.
    def available?
      Spotify.album_is_available(pointer)
    end

    # @return [Boolean] true if the album is loaded.
    def loaded?
      Spotify.album_is_loaded(pointer)
    end

    # @return [Artist, nil] album artist.
    def artist
      artist = Spotify.album_artist(pointer)
      Artist.from(artist)
    end

    # @see cover_link
    # @param [Symbol] size (see {Image.sizes})
    # @return [Image, nil] album cover as an Image.
    def cover(size = :normal)
      cover = Spotify.album_cover(pointer, size)
      Image.from(cover)
    end

    # @see cover
    # @param [Symbol] size (see {Image.sizes})
    # @return [Link, nil] album cover as a spotify URI.
    def cover_link(size = :normal)
      cover = Spotify.link_create_from_album_cover(pointer, size)
      Link.from(cover)
    end

    # Browse the Album by creating an {AlbumBrowse} instance from it.
    #
    # @return [AlbumBrowse] an album browsing object
    def browse
      AlbumBrowse.new(pointer)
    end
  end
end
