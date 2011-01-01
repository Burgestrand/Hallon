# coding: utf-8

# `libspotify` sometimes calls back to C-functions on certain events. Most of
# the library operations are asynchronous, and fire callbacks when they are
# finished. This means we must be able to handle the callbacks from Ruby.
# 
# I made a system that revolves around three threads and semaphores. It is
# described in `ext/hallon/events.h`.
# 
# Handler, however, is the module that needs to be included to cover all 
# possible callbacks. By default, it doesn’t do anything, except for processing
# events when required.
module Hallon::Handler
  # Build a handler given either a class, module and/or block.
  #
  # @private
  # @see Hallon::Handler
  # @param [Class<Hallon::Handler>, Module, nil] handler
  # @param [Block, nil] block
  # @return [Hallon::Handler]
  def self.build(handler = nil, block = nil)
    klass = if handler.is_a?(Class)
      raise ArgumentError, "must provide nil, module, or subclass of Hallon::Handler" unless Hallon::Handler >= handler
      handler
    else
      Class.new do
        include Hallon::Handler
        include handler if handler.is_a?(Module)
      end
    end
    
    klass.module_eval(&block) if block
    klass
  end
  
  # Returns the handlers’ associated session.
  # @return [Session]
  attr_reader :session

  # Associates the Handler with the given {Hallon::Session}.
  #
  # @param [Session] session
  def initialize(session)
    @session = session
  end
  
  
  ###
  # Session Callbacks
  
  # Session#process_events needs to be called.
  def process_events
    session.process_events
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