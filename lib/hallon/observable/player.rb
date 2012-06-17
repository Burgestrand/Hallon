module Hallon::Observable
  # We only care about a few of the Session callbacks, actually,
  # but since this object is not *really* a Spotify object we do
  # cheat a little bit.
  module Player
    # Includes {Hallon::Observable} for you.
    def self.extended(other)
      other.send(:include, Hallon::Observable)
    end

    protected

    # @return [Array<Method>] array of callback methods
    def initialize_callbacks
      %w(end_of_track streaming_error play_token_lost).map { |m| callback_for(m) }
    end

    # Dummy callback. See {Session#end_of_track_callback}.
    def end_of_track_callback(session)
    end

    # Dummy callback. See {Session#streaming_error_callback}.
    def streaming_error_callback(session, error)
    end

    # Dummy callback. See {Session#play_token_lost_callback}.
    def play_token_lost_callback(session)
    end
  end
end
