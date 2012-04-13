# coding: utf-8
require 'cgi'

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

    include Linkable

    to_link :from_search

    from_link :search do |link|
      link = Link.new(link).to_uri
      ::CGI.unescape(link[/\Aspotify:search:(.+)\z/m, 1])
    end

    extend Observable::Search
    include Loadable

    # @return [Hash] default search parameters
    def self.defaults
      @defaults ||= {
        :tracks  => 25,
        :albums  => 25,
        :artists => 25,
        :playlists => 25,
        :tracks_offset  => 0,
        :albums_offset  => 0,
        :artists_offset => 0,
        :playlists_offset => 0
      }
    end

    # Construct a new search with given query.
    #
    # @param [String, Link] search search query or spotify URI
    # @param [Hash] options additional search options
    # @option options [#to_i] :tracks (25) max number of tracks you want in result
    # @option options [#to_i] :albums (25) max number of albums you want in result
    # @option options [#to_i] :artists (25) max number of artists you want in result
    # @option options [#to_i] :playlists (25) max number of playlists you want in result
    # @option options [#to_i] :tracks_offset (0) offset of tracks in search result
    # @option options [#to_i] :albums_offset (0) offset of albums in search result
    # @option options [#to_i] :artists_offset (0) offset of artists in search result
    # @option options [#to_i] :playlists_offset (0) offset of playlists in search result
    # @see http://developer.spotify.com/en/libspotify/docs/group__search.html#gacf0b5e902e27d46ef8b1f40e332766df
    def initialize(search, options = {})
      opts = Search.defaults.merge(options)
      opts = opts.values_at(:tracks_offset, :tracks, :albums_offset, :albums, :artists_offset, :artists, :playlists_offset, :playlists).map(&:to_i)
      search = from_link(search) if Link.valid?(search)

      subscribe_for_callbacks do |callback|
        @pointer = if Spotify::Pointer.typechecks?(search, :search)
          search
        else
          Spotify.search_create!(session.pointer, search, *opts, :standard, callback, nil)
        end

        raise ArgumentError, "search with #{search} failed" if @pointer.null?
      end
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
      Spotify.search_query(pointer).to_s
    end

    # @return [String] “did you mean?” suggestion for current search.
    def did_you_mean
      Spotify.search_did_you_mean(pointer).to_s
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
  end
end
