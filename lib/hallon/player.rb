# coding: utf-8
module Hallon
  # A wrapper around Session for playing, stopping and otherwise
  # controlling the playback features of libspotify.
  #
  # @note This is very much a work in progress.
  # @see Session
  class Player
    # meep?
    extend Observable::Player

    # @return [Spotify::Pointer<Session>] session pointer
    attr_reader :pointer

    # @return [Array<Symbol>] a list of available playback bitrates.
    def self.bitrates
      Spotify.enum_type(:bitrate).symbols.sort_by do |sym|
        # sort by bitrate quality
        sym.to_s.to_i
      end
    end

    # Constructs a Player, given a Session.
    #
    # @example
    #   Hallon::Player.new(session) do
    #     on(:music_delivery) do |format, frames|
    #     end
    #
    #     on(:start_playback) do
    #     end
    #
    #     on(:stop_playback) do
    #     end
    #
    #     on(:play_token_lost) do
    #     end
    #
    #     on(:end_of_track) do
    #     end
    #
    #     on(:streaming_error) do |error|
    #     end
    #
    #     on(:buffer_size?) do
    #       # return the pair of [samples, dropouts] of your audiobuffer
    #     end
    #   end
    #
    # @param [Session] session
    # @yield instance_evals itself, allowing you to define callbacks using `on`
    def initialize(session, &block)
      instance_eval(&block) if block_given?

      @session = session
      @pointer = @session.pointer

      %w[
        start_playback stop_playback play_token_lost end_of_track
        streaming_error get_audio_buffer_stats music_delivery
      ].each do |cb|
        @session.on(cb) { |*args| trigger(cb, *args) }
      end
    end

    # Set preferred playback bitrate.
    #
    # @param [Symbol] bitrate one of :96k, :160k, :320k
    # @return [Symbol]
    def bitrate=(bitrate)
      Spotify.session_preferred_bitrate(pointer, bitrate)
    end

    # Loads a Track for playing.
    #
    # @param [Track, Link, String] track
    # @return [Player]
    # @raise [Error] if the track could not be loaded
    def load(track)
      track = Track.new(track) unless track.is_a?(Track)
      error = Spotify.session_player_load(pointer, track.pointer)
      tap { Error.maybe_raise(error) }
    end

    # Prepares a Track for playing, without loading it.
    #
    # @note You can only prefetch if caching is on.
    # @param [Track] track
    # @return [Player]
    def prefetch(track)
      error = Spotify.session_player_prefetch(pointer, track.pointer)
      tap { Error.maybe_raise(error) }
    end

    # Starts playing a Track by feeding data to your application.
    #
    # @example
    #   player.play("spotify:track:44FHDONpdYeDpmqyS3BLRP")
    #
    # @note If no track is given, will try to play currently {#load}ed track.
    # @param [Track, Link, String, nil] track
    # @return [Player]
    def play(track = nil)
      load(track) unless track.nil?
      tap { Spotify.session_player_play(pointer, true) }
    end

    # Pause playback of a Track.
    #
    # @return [Player]
    def pause
      tap { Spotify.session_player_play(pointer, false) }
    end

    # Stop playing current track and unload it.
    #
    # @return [Player]
    def stop
      tap { Spotify.session_player_unload(pointer) }
    end

    # Seek to the desired position of the currently loaded Track.
    #
    # @param [Numeric] seconds offset position in seconds
    # @return [Player]
    def seek(seconds)
      tap { Spotify.session_player_seek(pointer, seconds * 1000) }
    end

    # @return [Boolean] true if libspotify is set to normalize audio volume.
    def volume_normalization?
      Spotify.session_get_volume_normalization(pointer)
    end

    # @param [Boolean] normalize_volume true if libspotify should normalize audio volume.
    def volume_normalization=(normalize_volume)
      Spotify.session_set_volume_normalization(pointer, !! normalize_volume)
    end
  end
end
