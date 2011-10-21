module Hallon
  # A wrapper around Session for playing, stopping and otherwise
  # controlling the playback features of libspotify.
  #
  # @note This is very much a work in progress. Given Session still
  #       takes care of all callbacks, and the callbacks themselves
  #       must still be handled by means of Ruby FFI.
  # @see Session
  class Player
    include Observable

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
    #     on(:music_delivery) do |*frames|
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

      %w[start_playback stop_playback play_token_lost end_of_track streaming_error].each do |cb|
        @session.on(cb) { |*args| trigger(cb, *args) }
      end

      @session.on(:audio_buffer_stats) do |stats_ptr|
        stats = Spotify::AudioBufferStats.new(stats_ptr)
        samples, dropouts = trigger(:buffer_size?)
        stats[:samples]  = samples || 0
        stats[:dropouts] = dropouts || 0
      end

      @session.on(:music_delivery) do |format, frames, num_frames|
        trigger(:music_delivery, format, frames, num_frames)
        num_frames # assume we consume all data
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
    # @param [Track] track
    # @return [Player]
    # @raise [Error] if the track could not be loaded
    def load(track)
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
  end
end
