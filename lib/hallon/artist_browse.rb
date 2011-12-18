# coding: utf-8
module Hallon
  # ArtistBrowse is like AlbumBrowse, only that it’s for {Track}s.
  #
  # @see Artist
  # @see http://developer.spotify.com/en/libspotify/docs/group__artistbrowse.html
  class ArtistBrowse < Base
    extend Observable::ArtistBrowse

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
    # @note Returns nil if the request was served from the local libspotify cache.
    # @return [Rational, nil] time it took for the albumbrowse request to complete (in seconds).
    def request_duration
      duration = Spotify.artistbrowse_backend_request_duration(pointer)
      Rational(duration, 1000) if duration > 0
    end

    # Retrieve artist portraits as an {Image} or a {Link}.
    #
    # @param [Boolean] as_image true if you want an enumerator of Images (false for Links)
    # @return [Enumerator<Image>, Enumerator<Link>] artist portraits.
    def portraits(as_image = true)
      size = Spotify.artistbrowse_num_portraits(pointer)
      Enumerator.new(size) do |i|
        if as_image
          id = Spotify.artistbrowse_portrait(pointer, i).read_string(20)
          Image.new(id)
        else
          link = Spotify.link_create_from_artistbrowse_portrait!(pointer, i)
          Link.new(link)
        end
      end
    end

    # @return [Enumerator<Track>] artist authored tracks.
    def tracks
      size = Spotify.artistbrowse_num_tracks(pointer)
      Enumerator.new(size) do |i|
        track = Spotify.artistbrowse_track!(pointer, i)
        Track.new(track)
      end
    end

    # @return [Enumerator<Album>] artist authored albums.
    def albums
      size = Spotify.artistbrowse_num_albums(pointer)
      Enumerator.new(size) do |i|
        album = Spotify.artistbrowse_album!(pointer, i)
        Album.new(album)
      end
    end

    # @return [Enumartor<Artist>] similar artists to this artist.
    def similar_artists
      size = Spotify.artistbrowse_num_similar_artists(pointer)
      Enumerator.new(size) do |i|
        artist = Spotify.artistbrowse_similar_artist!(pointer, i)
        Artist.new(artist)
      end
    end
  end
end
