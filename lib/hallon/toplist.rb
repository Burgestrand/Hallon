# coding: utf-8
module Hallon
  # Toplists are what they sound like. They’re collections of
  # artists, albums or tracks popular in a certain area either
  # by country, user or everywhere.
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__toplist.html
  class Toplist < Base
    # Enumerates through all tracks of a toplist object.
    class Tracks < Enumerator
      size :toplistbrowse_num_tracks

      # @return [Track, nil]
      item :toplistbrowse_track! do |track|
        Track.from(track)
      end
    end

    # Enumerates through all albums of a toplist object.
    class Albums < Enumerator
      size :toplistbrowse_num_albums

      # @return [Album, nil]
      item :toplistbrowse_album! do |album|
        Album.from(album)
      end
    end

    # Enumerates through all albums of a toplist object.
    class Artists < Enumerator
      size :toplistbrowse_num_artists

      # @return [Artist, nil]
      item :toplistbrowse_artist! do |artist|
        Artist.from(artist)
      end
    end

    extend Observable::Toplist
    include Loadable

    # @return [Symbol] type of toplist request (one of :artists, :albums or :tracks)
    attr_reader :type

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

      subscribe_for_callbacks do |callback|
        @type    = type
        @pointer = Spotify.toplistbrowse_create!(session.pointer, type, region, user, callback, nil)
      end
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

    # @note the returned enumerator corresponds to the #type of Toplist.
    # @return [Artists, Albums, Tracks] an enumerator over the collection of results.
    def results
      klass = case type
      when :artists
        Artists
      when :albums
        Albums
      when :tracks
        Tracks
      end

      klass.new(self)
    end

    # @note If the object is not loaded, the result is undefined.
    # @return [Rational] time it took for the toplistbrowse request to complete (in seconds).
    def request_duration
      duration = Spotify.toplistbrowse_backend_request_duration(pointer)
      duration = 0 if duration < 0
      Rational(duration, 1000)
    end

    private
      # Convert a given two-character region to a Spotify
      # compliant region (encoded in a 16bit integer).
      #
      # @param [#to_s] region
      # @return [Integer]
      def to_country(region)
        code = region.to_s.upcase
        high, low = code.bytes.take(2)
        (high << 8) | low
      end
  end
end
