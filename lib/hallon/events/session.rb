# Session callbacks
# 
# This is a Handler module for all possible Session events and an explanation
# for each event.
# 
# @see http://developer.spotify.com/en/libspotify/docs/structsp__session__callbacks.html
module Hallon::Events::Session
  # Session#process_events needs to be called.
  def process_events
    subject.process_events
  end

  # Login has been processed and was successful.
  # 
  # @param [Fixnum]
  def logged_in(error) # TODO: body
  end

  # Logout has been processed. Either called explicitly if you logout, or
  # implicitly if there’s a permanent connection error.
  def logged_out
  end

  # Metadata has been updated (for any object)
  def metadata_updated
  end

  # There’s a connection error, and libspotify has problems reconnecting. Can
  # be called multiple times (as long as problem is present).
  # 
  # @param [String]
  def connection_error(error)
  end

  # Spotify wants to display a message to the user.
  # 
  # @param [String]
  def message_to_user(message)
  end

  # Log message from libspotify.
  # 
  # @param [String]
  def log_message(data)
  end

  # User info (for any user) have been updated.
  def userinfo_updated
  end

  # Streaming cannot start or continue.
  # 
  # @param [Fixnum]
  def streaming_error(error)
  end

  # Music has been paused, because only one account may play music at the same time.
  def play_token_lost
  end

  # Audio playback should start.
  # 
  # @note This function must never block.
  def start_playback
  end

  # Audio playback should stop.
  def stop_playback
  end

  # Currently played track has reached its’ end.
  def end_of_track
  end

  # There is decompressed audio data available.
  # 
  # @note This function is not yet implemented.
  # @note This function must never block.
  # @return [Fixnum]
  def music_delivery(format, *frames) # TODO: body
    0
  end

  # Query application about its’ audio buffer.
  # 
  # @note This function is not yet implemented.
  # @note This function must never block.
  def get_audio_buffer_stats(stats)
  end
end