# coding: utf-8
module Hallon
  # An ArtistBrowse object is for retrieving details about a given artist, such
  # as it’s tracks, albums, similar artists and more.
  #
  # @see Artist
  # @see http://developer.spotify.com/en/libspotify/docs/group__artistbrowse.html
  class ArtistBrowse < Base
    # Enumerates through all portrait images of an artist browsing object.
    class Portraits < Enumerator
      size :artistbrowse_num_portraits

      # @return [Image, nil]
      item :artistbrowse_portrait do |portrait|
        Image.new(portrait)
      end
    end

    # Enumerates through all portrait links of an artist browsing object.
    class PortraitLinks < Enumerator
      size :artistbrowse_num_portraits

      # @return [Link, nil]
      item :link_create_from_artistbrowse_portrait! do |portrait|
        Link.from(portrait)
      end
    end

    # Enumerates through all tracks of an artist browsing object.
    class Tracks < Enumerator
      size :artistbrowse_num_tracks

      # @return [Track, nil]
      item :artistbrowse_track! do |track|
        Track.from(track)
      end
    end

    # Enumerates through all albums of an artist browsing object.
    class Albums < Enumerator
      size :artistbrowse_num_albums

      # @return [Album, nil]
      item :artistbrowse_album! do |album|
        Album.from(album)
      end
    end

    # Enumerates through all similar artists of an artist browsing object.
    class SimilarArtists < Enumerator
      size :artistbrowse_num_similar_artists

      # @return [Artist, nil]
      item :artistbrowse_similar_artist! do |artist|
        Artist.from(artist)
      end
    end

    # Enumerates through all tophit tracks of an album browsing object.
    class TopHits < Enumerator
      size :artistbrowse_num_tophit_tracks

      # @return [Track, nil]
      item :artistbrowse_tophit_track! do |track|
        Track.from(track)
      end
    end

    extend Observable::ArtistBrowse
    include Loadable

    # @return [Array<Symbol>] artist browsing types for use in {#initialize}
    def self.types
      Spotify.enum_type(:artistbrowse_type).symbols
    end

    # Creates an ArtistBrowse instance from an Artist or an Artist pointer.
    #
    # @note Also use {Artist#browse} to browse an Artist.
    # @param [Artist, Spotify::Pointer] artist
    # @param [Symbol] type (see {.types})
    def initialize(artist, type = :full)
      pointer = artist
      pointer = pointer.pointer if pointer.respond_to?(:pointer)

      unless Spotify::Pointer.typechecks?(pointer, :artist)
        given = pointer.respond_to?(:type) ? pointer.type : pointer.inspect
        raise TypeError, "expected artist pointer, was given #{given}"
      end

      subscribe_for_callbacks do |callback|
        @pointer = Spotify.artistbrowse_create!(session.pointer, pointer, type, callback, nil)
      end

      raise FFI::NullPointerError, "artist browsing failed" if @pointer.null?
    end

    # @return [Boolean] true if the artist browser is loaded.
    def loaded?
      Spotify.artistbrowse_is_loaded(pointer)
    end

    # @see Error.explain
    # @return [Symbol] artist browser error status.
    def status
      Spotify.artistbrowse_error(pointer)
    end

    # @return [Artist, nil] artist this browser is browsing.
    def artist
      artist = Spotify.artistbrowse_artist!(pointer)
      Artist.from(artist)
    end

    # @return [String] artist biography.
    def biography
      Spotify.artistbrowse_biography(pointer)
    end

    # @note If the object is not loaded, the result is undefined.
    # @return [Rational] time it took for the albumbrowse request to complete (in seconds).
    def request_duration
      duration = Spotify.artistbrowse_backend_request_duration(pointer)
      duration = 0 if duration < 0
      Rational(duration, 1000)
    end

    # @return [Portraits] artist portraits as {Image}s.
    def portraits
      Portraits.new(self)
    end

    # @return [PortraitImages] artist portraits as {Link}s.
    def portrait_links
      PortraitLinks.new(self)
    end

    # @return [Tracks] artist authored tracks.
    def tracks
      Tracks.new(self)
    end

    # @return [Albums] artist authored albums.
    def albums
      Albums.new(self)
    end

    # @return [SimilarArtists] similar artists to this artist.
    def similar_artists
      SimilarArtists.new(self)
    end

    # @return [TopHits] enumerator of the artist’s most popular tracks.
    def top_hits
      TopHits.new(self)
    end
  end
end
