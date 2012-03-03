# coding: utf-8
module Hallon
  # Search allows you to search Spotify for tracks, albums
  # and artists, just like in the client.
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__search.html
  class Search < Base
    # Enumerates through all tracks of a search object.
    class Tracks < Enumerator
      size :search_num_tracks

      # @return [Track, nil]
      item :search_track! do |track|
        Track.from(track)
      end

      # @return [Integer] total number of tracks from connected search result.
      def total
        Spotify.search_total_tracks(pointer)
      end
    end

    # Enumerates through all albums of a search object.
    class Albums < Enumerator
      size :search_num_albums

      # @return [Album, nil]
      item :search_album! do |album|
        Album.from(album)
      end

      # @return [Integer] total number of tracks from connected search result.
      def total
        Spotify.search_total_albums(pointer)
      end
    end

    # Enumerates through all albums of a search object.
    class Artists < Enumerator
      size :search_num_artists

      # @return [Artist, nil]
      item :search_artist! do |artist|
        Artist.from(artist)
      end

      # @return [Integer] total tracks available from connected search result.
      def total
        Spotify.search_total_artists(pointer)
      end
    end

    extend Observable::Search
    include Loadable

    # @return [Array<Symbol>] a list of radio genres available for search
    def self.genres
      Spotify.enum_type(:radio_genre).symbols
    end

    # @return [Hash] default search parameters
    def self.defaults
      @defaults ||= {
        :tracks  => 25,
        :albums  => 25,
        :artists => 25,
        :tracks_offset  => 0,
        :albums_offset  => 0,
        :artists_offset => 0
      }
    end

    # @param [Range<Integer>] range (from_year..to_year)
    # @param [Symbol, …] genres
    # @return [Search] radio search in given period and genres
    def self.radio(range, *genres)
      from_year, to_year = range.begin, range.end
      genres = genres.reduce(0) do |mask, genre|
        mask | Spotify.enum_value!(genre, "genre")
      end

      search = allocate
      search.instance_eval do
        subscribe_for_callbacks do |callback|
          @pointer = Spotify.radio_search_create!(session.pointer, from_year, to_year, genres, callback, nil)
        end

        raise FFI::NullPointerError, "radio search failed" if pointer.null?
      end

      search
    end

    # Construct a new search with given query.
    #
    # @param [String] query search query
    # @param [Hash] options additional search options
    # @option options [#to_i] :tracks (25) max number of tracks you want in result
    # @option options [#to_i] :albums (25) max number of albums you want in result
    # @option options [#to_i] :artists (25) max number of artists you want in result
    # @option options [#to_i] :tracks_offset (0) offset of tracks in search result
    # @option options [#to_i] :albums_offset (0) offset of albums in search result
    # @option options [#to_i] :artists_offset (0) offset of artists in search result
    # @see http://developer.spotify.com/en/libspotify/docs/group__search.html#gacf0b5e902e27d46ef8b1f40e332766df
    def initialize(query, options = {})
      opts = Search.defaults.merge(options)
      opts = opts.values_at(:tracks_offset, :tracks, :albums_offset, :albums, :artists_offset, :artists).map(&:to_i)

      subscribe_for_callbacks do |callback|
        @pointer  = Spotify.search_create!(session.pointer, query, *opts, callback, nil)
      end

      raise FFI::NullPointerError, "search for “#{query}” failed" if pointer.null?
    end

    # @return [Boolean] true if the search has been fully loaded.
    def loaded?
      Spotify.search_is_loaded(pointer)
    end

    # @see Error.explain
    # @return [Symbol] search error status.
    def status
      Spotify.search_error(pointer)
    end

    # @return [String] search query this search was created with.
    def query
      Spotify.search_query(pointer)
    end

    # @return [String] “did you mean?” suggestion for current search.
    def did_you_mean
      Spotify.search_did_you_mean(pointer)
    end

    # @return [Tracks] list of all tracks in the search result.
    def tracks
      Tracks.new(self)
    end

    # @return [Albums] list of all albums in the search result.
    def albums
      Albums.new(self)
    end

    # @return [Artists] list of all artists in the search result.
    def artists
      Artists.new(self)
    end

    # @return [Link] link for this search query.
    def to_link
      link = Spotify.link_create_from_search!(pointer)
      Link.from(link)
    end
  end
end
