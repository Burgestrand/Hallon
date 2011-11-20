# coding: utf-8
module Hallon
  # Toplists are what they sound like. They’re collections of
  # artists, albums or tracks popular in a certain area either
  # by country, user or everywhere.
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__toplist.html
  class Toplist < Base
    include Observable

    # Create a Toplist browsing object.
    #
    # @overload initialize(type, username)
    # @overload initialize(type, country)
    # @overload initialize(type)
    #
    # @example with a given username
    #   toplist = Hallon::Toplist.new(:artists, "burgestrand")
    #
    # @example with a given country
    #   toplist = Hallon::Toplist.new(:tracks, :se)
    #
    # @example everywhere
    #   toplist = Hallon::Toplist.new(:albums)
    #
    # @param [Symbol] type one of :artists, :albums or :tracks
    # @param [String, Symbol, nil] region username, 2-letter country code or nil
    def initialize(type, region = nil)
      case region
      when String
        user   = region
        region = :user
      when NilClass
        region = :everywhere
      when Symbol
        region = to_country(region)
      end

      @callback = proc { trigger(:load) }
      @pointer  = Spotify.toplistbrowse_create!(session.pointer, type, region, user, @callback, nil)
    end

    # @return [Boolean] true if the toplist is loaded.
    def loaded?
      Spotify.toplistbrowse_is_loaded(pointer)
    end

    # @see Error.explain
    # @return [Symbol] toplist error status.
    def status
      Spotify.toplistbrowse_error(pointer)
    end

    # @return [Enumerator<Artist>] a list of artists.
    def artists
      size = Spotify.toplistbrowse_num_artists(pointer)
      Enumerator.new(size) do |i|
        artist = Spotify.toplistbrowse_artist!(pointer, i)
        Artist.new(artist)
      end
    end

    # @return [Enumerator<Album>] a list of albums.
    def albums
      size = Spotify.toplistbrowse_num_albums(pointer)
      Enumerator.new(size) do |i|
        album = Spotify.toplistbrowse_album!(pointer, i)
        Album.new(album)
      end
    end

    # @return [Enumerator<Track>] a list of tracks.
    def tracks
      size = Spotify.toplistbrowse_num_tracks(pointer)
      Enumerator.new(size) do |i|
        track = Spotify.toplistbrowse_track!(pointer, i)
        Track.new(track)
      end
    end

    # @note If the object is not loaded, the result is undefined.
    # @note Returns nil if the request was served from the local libspotify cache.
    # @return [Rational, nil] time it took for the toplistbrowse request to complete (in seconds).
    def request_duration
      duration = Spotify.toplistbrowse_backend_request_duration(pointer)
      Rational(duration, 1000) if duration > 0
    end

    private
      # Convert a given two-character region to a Spotify
      # compliant region (encoded in a 16bit integer).
      #
      # @param [#to_s]
      # @return [Integer]
      def to_country(region)
        code = region.to_s.upcase
        high, low = code.bytes.take(2)
        (high << 8) | low
      end
  end
end
