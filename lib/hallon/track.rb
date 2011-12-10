# coding: utf-8
module Hallon
  # Tracks are an essential part to the Spotify service. They
  # are browsable entities that can also be played by streaming.
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__track.html
  class Track < Base
    extend Linkable

    from_link :as_track_and_offset
    to_link   :from_track

    # Overriden to use default parameter.
    # @see #to_link
    alias_method :_to_link, :to_link

    # Create a Link to the current track and offset in seconds.
    #
    # @param [Float] offset offset into track in seconds
    # @return [Hallon::Link]
    def to_link(offset = offset)
      _to_link((offset * 1000).to_i)
    end

    # Offset into track in seconds this track was created with.
    #
    # @return [Rational]
    attr_reader :offset

    # Construct a new Track instance.
    #
    # @param [String, Link, FFI::Pointer] link
    def initialize(link)
      FFI::MemoryPointer.new(:int) do |ptr|
        @pointer = to_pointer(link, :track, ptr)
        @offset  = Rational(ptr.read_int, 1000)
      end
    end

    # Create a new local track.
    #
    # @param [String] title
    # @param [String] artist
    # @param [String] album
    # @param [Integer] length
    # @return [Track]
    def self.local(title, artist, album = nil, length = nil)
      track = Spotify.localtrack_create!(artist, title, album || "", length || -1)
      new(track)
    end

    # @note This’ll be an empty string unless the track is loaded.
    # @return [String]
    def name
      Spotify.track_name(pointer)
    end

    # Duration of the track in seconds.
    #
    # @note This’ll be `0` unless the track is loaded.
    # @return [Rational]
    def duration
      Rational(Spotify.track_duration(pointer), 1000)
    end

    # Track popularity, between 0 and 1.
    #
    # @note This’ll be `0` unless the track is loaded.
    # @return [Rational]
    def popularity
      Rational(Spotify.track_popularity(pointer), 100)
    end

    # Disc number this track appears in.
    #
    # @note This function is a bit special. See libspotify docs for details.
    def disc
      Spotify.track_disc(pointer)
    end

    # @note This function is a bit special. See libspotify docs for details.
    # @return [Integer] position of track on its’ disc.
    def index
      Spotify.track_index(pointer)
    end

    # @see Error.explain
    # @return [Symbol] track error status.
    def status
      Spotify.track_error(pointer)
    end

    # @return [Boolean] true if track is loaded.
    def loaded?
      Spotify.track_is_loaded(pointer)
    end

    # @note Track does not have to be loaded for this to return a useful value.
    #
    # @note Placeholder tracks are not really tracks, but merely containers
    # for other objects to allow storing them in playlists such as the inbox.
    #
    # @return [Boolean] true if the track is a placeholder.
    # @see unwrap
    def placeholder?
      Spotify.track_is_placeholder(pointer)
    end

    # Unwraps a {#placeholder?} Track into its’ real object.
    #
    # @see placeholder?
    # @return [Track, Artist, Album, Playlist]
    def unwrap
      return self unless placeholder?

      case (link = to_link).type
      when :playlist
        Playlist.new(link)
      when :album
        Album.new(link)
      when :artist
        Artist.new(link)
      end
    end

    # @return [Symbol] track offline status.
    def offline_status
      Spotify.track_offline_get_status(pointer)
    end

    # @note This’ll be `nil` unless the track is loaded.
    # @return [Hallon::Album] album this track belongs to.
    def album
      album = Spotify.track_album!(pointer)
      Album.from(album)
    end

    # @note There may be more than one artist, see {#artists} for retrieving them all!
    # @see #artists
    # @return [Hallon::Artist, nil] artist who performed this track.
    def artist
      artists.first
    end

    # @note Track must be loaded, or you’ll get zero artists.
    # @return [Hallon::Enumerator<Artist>] all {Artist}s who performed this Track.
    def artists
      size = Spotify.track_num_artists(pointer)
      Enumerator.new(size) do |i|
        artist = Spotify.track_artist!(pointer, i)
        Artist.new(artist)
      end
    end

    # @note This’ll always return false unless the track is loaded.
    # @return [Boolean] true if {#availability} is available.
    def available?
      availability == :available
    end

    # Track availability.
    #
    # @return [Symbol] :unavailable, :available, :not_streamable, :banned_by_artist
    def availability
      Spotify.track_get_availability(session.pointer, pointer)
    end

    # @note This’ll always return false unless the track is loaded.
    # @return [Boolean] true if the track is a local track.
    def local?
      Spotify.track_is_local(session.pointer, pointer)
    end

    # @note This’ll always return false unless the track is loaded.
    # @return [Boolean] true if the track is autolinked.
    def autolinked?
      Spotify.track_is_autolinked(session.pointer, pointer)
    end

    # @note This’ll always return false unless the track is loaded.
    # @return [Boolean] true if the track is starred.
    def starred?
      Spotify.track_is_starred(session.pointer, pointer)
    end

    # Set {#starred?} status of current track.
    #
    # @note It’ll set the starred status for the current Session.instance.
    # @param [Boolean] starred
    # @return [Boolean]
    def starred=(starred)
      starred ? session.star(self) : session.unstar(self)
    end
  end
end
