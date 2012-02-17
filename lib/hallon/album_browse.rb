# coding: utf-8
module Hallon
  # AlbumBrowse objects are for retrieving additional data from
  # an album that cannot otherwise be acquired. This includes
  # tracks, reviews, copyright information.
  #
  # @see Album
  # @see http://developer.spotify.com/en/libspotify/docs/group__albumbrowse.html
  class AlbumBrowse < Base
    # Enumerates through all copyright notices of an album browsing object.
    class Copyrights < Enumerator
      size :albumbrowse_num_copyrights

      # @return [String, nil]
      item :albumbrowse_copyright
    end

    # Enumerates through all tracks of an album browsing object.
    class Tracks < Enumerator
      size :albumbrowse_num_tracks

      # @return [Track, nil]
      item :albumbrowse_track! do |track|
        Track.from(track)
      end
    end

    extend Observable::AlbumBrowse
    include Loadable

    # Creates an AlbumBrowse instance from an Album or an Album pointer.
    #
    # @note Also {Album#browse} to browse an Album.
    # @param [Album, Spotify::Pointer] album
    def initialize(album)
      pointer = album
      pointer = pointer.pointer if pointer.respond_to?(:pointer)

      unless Spotify::Pointer.typechecks?(pointer, :album)
        given = pointer.respond_to?(:type) ? pointer.type : pointer.inspect
        raise TypeError, "expected album pointer, was given #{given}"
      end

      subscribe_for_callbacks do |callback|
        @pointer = Spotify.albumbrowse_create!(session.pointer, pointer, callback, nil)
      end

      raise FFI::NullPointerError, "album browsing failed" if @pointer.null?
    end

    # @return [Boolean] true if the album browser is loaded.
    def loaded?
      Spotify.albumbrowse_is_loaded(pointer)
    end

    # @see Error.explain
    # @return [Symbol] album browser error status.
    def status
      Spotify.albumbrowse_error(pointer)
    end

    # @return [String] album review.
    def review
      Spotify.albumbrowse_review(pointer)
    end

    # @return [Artist, nil] artist performing this album.
    def artist
      artist = Spotify.albumbrowse_artist!(pointer)
      Artist.from(artist)
    end

    # @return [Album, nil] album this object is browsing.
    def album
      album = Spotify.albumbrowse_album!(pointer)
      Album.from(album)
    end

    # @note If the object is not loaded, the result is undefined.
    # @note Returns nil if the request was served from the local libspotify cache.
    # @return [Rational, nil] time it took for the albumbrowse request to complete (in seconds).
    def request_duration
      duration = Spotify.albumbrowse_backend_request_duration(pointer)
      Rational(duration, 1000) if duration > 0
    end

    # @return [Copyrights] enumerator of copyright notices.
    def copyrights
      Copyrights.new(self)
    end

    # @return [Tracks] enumerator of tracks.
    def tracks
      Tracks.new(self)
    end
  end
end
