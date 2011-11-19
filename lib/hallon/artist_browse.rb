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

    # @return [Array<Symbol>] artist browsing types for use in {#initialize}
    def self.types
      Spotify.enum_type(:artistbrowse_type).symbols
    end

    # Creates an ArtistBrowse instance from an Artist or an Artist pointer.
    #
    # @note Use {Artist#browse} to browse an Artist.
    # @param [Artist, Spotify::Pointer] artist
    # @param [Symbol] type (see {.types})
    def initialize(artist, type = :full)
      pointer = artist
      pointer = pointer.pointer if pointer.respond_to?(:pointer)

      unless Spotify::Pointer.typechecks?(pointer, :artist)
        given = pointer.respond_to?(:type) ? pointer.type : pointer.inspect
        raise TypeError, "expected artist pointer, was given #{given}"
      end

      @callback = proc { trigger(:load) }
      @pointer  = Spotify.artistbrowse_create!(session.pointer, pointer, type, @callback, nil)
    end

    # @return [Boolean] true if the album browser is loaded
    def loaded?
      Spotify.artistbrowse_is_loaded(pointer)
    end

    # @see Error
    # @return [Symbol] artist browser error status
    def error
      Spotify.artistbrowse_error(pointer)
    end

    # @return [Artist, nil] artist this browser is browsing
    def artist
      artist = Spotify.artistbrowse_artist!(pointer)
      Artist.new(artist) unless artist.null?
    end

    # @return [String] artist biography
    def biography
      Spotify.artistbrowse_biography(pointer)
    end

    # @param [Boolean] as_image true if you want an enumerator of Images (false for Links)
    # @return [Enumerator<Image>, Enumerator<Link>] artist portraits
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

    # @return [Enumerator<Track>] artist authored tracks
    def tracks
      size = Spotify.artistbrowse_num_tracks(pointer)
      Enumerator.new(size) do |i|
        track = Spotify.artistbrowse_track!(pointer, i)
        Track.new(track)
      end
    end

    # @return [Enumerator<Album>] artist authored albums
    def albums
      size = Spotify.artistbrowse_num_albums(pointer)
      Enumerator.new(size) do |i|
        album = Spotify.artistbrowse_album!(pointer, i)
        Album.new(album)
      end
    end

    # @return [Enumartor<Artist>] similar artists to this artist
    def similar_artists
      size = Spotify.artistbrowse_num_similar_artists(pointer)
      Enumerator.new(size) do |i|
        artist = Spotify.artistbrowse_similar_artist!(pointer, i)
        Artist.new(artist)
      end
    end
  end
end
