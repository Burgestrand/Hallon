# coding: utf-8
module Hallon
  # Search allows you to search Spotify for tracks, albums
  # and artists, just like in the client.
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__search.html
  class Search < Base
    include Observable

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
        @callback = proc { search.trigger(:load) }
        @pointer   = Spotify.radio_search_create!(session.pointer, from_year, to_year, genres, @callback, nil)

        raise FFI::NullPointerError, "radio search failed" if @pointer.null?
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
      o = Search.defaults.merge(options)
      @callback = proc { trigger(:load) }
      @pointer = Spotify.search_create!(session.pointer, query, o[:tracks_offset].to_i, o[:tracks].to_i, o[:albums_offset].to_i, o[:albums].to_i, o[:artists_offset].to_i, o[:artists].to_i, @callback, nil)

      raise FFI::NullPointerError, "search for “#{query}” failed" if @pointer.null?
    end

    # @return [Boolean] true if the search has been fully loaded
    def loaded?
      Spotify.search_is_loaded(pointer)
    end

    # @return [Symbol] error status
    def error
      Spotify.search_error(pointer)
    end

    # @return [String] search query this search was created with
    def query
      Spotify.search_query(pointer)
    end

    # @return [String] “did you mean?” suggestion for current search
    def did_you_mean
      Spotify.search_did_you_mean(pointer)
    end

    # @return [Enumerator<Track>] enumerate over all tracks in the search result
    def tracks
      size = Spotify.search_num_tracks(pointer)
      Enumerator.new(size) do |i|
        track = Spotify.search_track!(pointer, i)
        Track.new(track)
      end
    end

    # @return [Integer] total tracks available for this search query
    def total_tracks
      Spotify.search_total_tracks(pointer)
    end

    # @return [Enumerator<Album>] enumerate over all albums in the search result
    def albums
      size  = Spotify.search_num_albums(pointer)
      Enumerator.new(size) do |i|
        album = Spotify.search_album!(pointer, i)
        Album.new(album)
      end
    end

    # @return [Integer] total tracks available for this search query
    def total_albums
      Spotify.search_total_albums(pointer)
    end

    # @return [Enumerator<Artist>] enumerate over all artists in the search result
    def artists
      size = Spotify.search_num_artists(pointer)
      Enumerator.new(size) do |i|
        artist = Spotify.search_artist!(pointer, i)
        Artist.new(artist)
      end
    end

    # @return [Integer] total tracks available for this search query
    def total_artists
      Spotify.search_total_artists(pointer)
    end

    # @return [Link] link for this search query
    def to_link
      link = Spotify.link_create_from_search!(pointer)
      Link.new(link) unless link.null?
    end
  end
end
