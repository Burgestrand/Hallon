module Hallon
  # ArtistBrowse is like AlbumBrowse, only that it’s for {Track}s.
  #
  # When it loads, it triggers the load callback on itself, that
  # can be utilized by giving {#on}(:load) a block to execute.
  #
  # @example
  #   browse = artist.browse # artist is a Hallon::Artist
  #   browse.on(:load) do
  #     puts "#{browse.artist.name} browser has been loaded!"
  #   end
  #   session.wait_for { browse.loaded? }
  #
  # @see Artist
  # @see http://developer.spotify.com/en/libspotify/docs/group__artistbrowse.html
  class ArtistBrowse < Base
    include Observable

    # Creates an ArtistBrowse instance from an Artist or an Artist pointer.
    #
    # @note Use {Artist#browse} to browse an Artist.
    # @param [Artist, FFI::Pointer] artist
    def initialize(artist)
      artist  = artist.pointer if artist.respond_to?(:pointer)
      @callback = proc { trigger(:load) }

      artistbrowse = Spotify.artistbrowse_create(session.pointer, artist, @callback, nil)
      @pointer     = Spotify::Pointer.new(artistbrowse, :artistbrowse, false)
    end

    # @return [Boolean] true if the album browser is loaded
    def loaded?
      Spotify.artistbrowse_is_loaded(@pointer)
    end

    # @see Error
    # @return [Symbol] artist browser error status
    def error
      Spotify.artistbrowse_error(@pointer)
    end

    # @return [Artist, nil] artist this browser is browsing
    def artist
      artist = Spotify.artistbrowse_artist(@pointer)
      Artist.new(artist) unless artist.null?
    end

    # @return [String] artist biography
    def biography
      Spotify.artistbrowse_biography(@pointer)
    end

    # @return [Enumerator<Image>] artist portraits
    def portraits
      size = Spotify.artistbrowse_num_portraits(@pointer)
      Enumerator.new(size) do |i|
        id = Spotify.artistbrowse_portrait(@pointer, i).read_string(20)
        Image.new(id)
      end
    end

    # @return [Enumerator<Track>] artist authored tracks
    def tracks
      size = Spotify.artistbrowse_num_tracks(@pointer)
      Enumerator.new(size) do |i|
        track = Spotify.artistbrowse_track!(@pointer, i)
        Track.new(track)
      end
    end

    # @return [Enumerator<Album>] artist authored albums
    def albums
      size = Spotify.artistbrowse_num_albums(@pointer)
      Enumerator.new(size) do |i|
        album = Spotify.artistbrowse_album(@pointer, i)
        Album.new(album)
      end
    end

    # @return [Enumartor<Artist>] similar artists to this artist
    def similar_artists
      size = Spotify.artistbrowse_num_similar_artists(@pointer)
      Enumerator.new(size) do |i|
        artist = Spotify.artistbrowse_similar_artist(@pointer, i)
        Artist.new(artist)
      end
    end
  end
end
