# coding: utf-8
module Hallon::Observable
  # Callbacks related to the {Hallon::Session} object.
  module Session
    # Includes {Hallon::Observable} for you.
    def self.extended(other)
      other.send(:include, Hallon::Observable)
    end

    protected

    # @return [Spotify::SessionCallbacks]
    def initialize_callbacks
      struct = Spotify::SessionCallbacks.new
      struct.members.each do |member|
        struct[member] = callback_for(member)
      end
      struct
    end

    # @example listening to this event
    #   session.on(:logged_in) do |error|
    #     puts "Logged in: " + Hallon::Error.explain(error)
    #   end
    #
    # @yield [error] logged_in
    # @yieldparam [Symbol] error
    # @see Error
    def logged_in_callback(pointer, error)
      trigger(pointer, :logged_in, error)
    end

    # @example listening to this event
    #   session.on(:logged_out) do
    #     puts "AHHH!"
    #   end
    #
    # @yield []
    def logged_out_callback(pointer)
      trigger(pointer, :logged_out)
    end

    # @example listening to this event
    #   session.on(:metadata_updated) do
    #     puts "wut wut"
    #   end
    #
    # @yield []
    def metadata_updated_callback(pointer)
      trigger(pointer, :metadata_updated)
    end

    # @example listening to this event
    #   session.on(:connection_error) do |error|
    #     puts "Oh noes: " + Hallon::Error.explain(error)
    #   end
    #
    # @yield [error]
    # @yieldparam [Symbol] error
    # @see Error
    def connection_error_callback(pointer, error)
      trigger(pointer, :connection_error, error)
    end

    # @example listening to this event
    #   session.on(:message_to_user) do |message|
    #     puts "OH HAI: #{message}"
    #   end
    #
    # @yield [message]
    # @yieldparam [String] message
    def message_to_user_callback(pointer, message)
      trigger(pointer, :message_to_user, message)
    end

    # @example listening to this event
    #   session.on(:notify_main_thread) do
    #     puts "main thread turn on"
    #   end
    #
    # @yield []
    def notify_main_thread_callback(pointer)
      trigger(pointer, :notify_main_thread)
    end

    # @example listening to this event
    #   session.on(:music_delivery) do |format, frames|
    #     puts ""
    #   end
    #
    # @yield [format, frames]
    # @yieldparam [Hash] format (contains :type, :rate, :channels)
    # @yieldparam [Enumerator<[Integer...]>] frames (each frame is an array containing format[:channels] integers of format[:type])
    def music_delivery_callback(pointer, format_struct, frames, num_frames)
      format = {
        rate: format_struct[:sample_rate],
        channels: format_struct[:channels],
        type: format_struct[:sample_type]
      }

      # read the frames of the given type
      frames = unless num_frames.zero?
        frames.public_send("read_array_of_#{format[:type]}", num_frames * format[:channels])
      else
        [] # when seeking, for example, num_frames will be zero and frames will be nil
      end

      # pass the frames to the callback, allowing it to do whatever
      consumed_frames = trigger(pointer, :music_delivery, format, frames.each_slice(format[:channels]))

      # finally return how many frames the callback reportedly consumed
      consumed_frames.to_i # very important to return something good here!
    end

    # @example listening to this event
    #   session.on(:play_token_lost) do
    #     puts "another user set us up the bomb!"
    #   end
    #
    # @yield []
    def play_token_lost_callback(pointer)
      trigger(pointer, :play_token_lost)
    end

    # @example listening to this event
    #   session.on(:end_of_track) do
    #     puts "all your base are belong to us"
    #   end
    #
    # @yield []
    def end_of_track_callback(pointer)
      trigger(pointer, :end_of_track)
    end

    # @example listening to this event
    #   session.on(:start_playback) do
    #     puts "dum dum tiss"
    #   end
    #
    # @yield []
    def start_playback_callback(pointer)
      trigger(pointer, :start_playback)
    end

    # @example listening to this event
    #   session.on(:stop_playback) do
    #     puts "dum dum tiss"
    #   end
    #
    # @yield []
    def stop_playback_callback(pointer)
      trigger(pointer, :stop_playback)
    end

    # @example listening to this event
    #   session.on(:get_audio_buffer_stats) do
    #     puts "que?"
    #   end
    #
    # @yield []
    # @yieldreturn an integer pair, [samples, dropouts]
    def get_audio_buffer_stats_callback(pointer, stats)
      samples, dropouts = trigger(pointer, :get_audio_buffer_stats)
      stats[:samples]  = samples.to_i
      stats[:stutter] = dropouts.to_i
    end

    # @example listening to this event
    #   session.on(:streaming_error) do |error|
    #     puts "boo: " + Hallon::Error.explain(error)
    #   end
    #
    # @yield [error]
    # @yieldparam [Symbol] error
    def streaming_error_callback(pointer, error)
      trigger(pointer, :streaming_error, error)
    end

    # @example listening to this event
    #   session.on(:userinfo_updated) do
    #     puts "who am I?!"
    #   end
    #
    # @yield []
    def userinfo_updated_callback(pointer)
      trigger(pointer, :userinfo_updated)
    end

    # @example listening to this event
    #   session.on(:log_message) do |message|
    #     puts "for great justice: #{message}"
    #   end
    #
    # @yield [message]
    # @yieldparam [String] message
    def log_message_callback(pointer, message)
      trigger(pointer, :log_message, message)
    end

    # @example listening to this event
    #   session.on(:offline_status_updated) do |session|
    #     puts "All systems: #{session.status}"
    #   end
    #
    # @yield []
    def offline_status_updated_callback(pointer)
      trigger(pointer, :offline_status_updated)
    end

    # @example listening to this event
    #   session.on(:offline_error) do |error|
    #     puts "FAIL: " + Hallon::Error.explain(error)
    #   end
    #
    # @yield [error]
    # @yieldparam [Symbol] error
    def offline_error_callback(pointer, error)
      trigger(pointer, :offline_error, error)
    end


    # @example listening to this event
    #   session.on(:credentials_blob_updated) do |credentials|
    #     File.open('.spotify-credentials', 'w') { |io| io.write(credentials) }
    #   end
    #
    # @yield [credentials]
    # @yieldparam [String] credentials
    def credentials_blob_updated_callback(pointer, credentials)
      trigger(pointer, :credentials_blob_updated, credentials)
    end

    # @example listening to this event
    #   session.on(:connectionstate_updated) do
    #     puts "Yay! Connection state changed… hooray… wee… no?"
    #   end
    #
    # @yield
    def connectionstate_updated_callback(pointer)
      trigger(pointer, :connectionstate_updated)
    end

    # @example listening to this event
    #   session.on(:scrobble_error) do |error|
    #     Hallon::Error.maybe_raise(error)
    #   end
    #
    # @yield
    def scrobble_error_callback(pointer, error)
      trigger(pointer, :scrobble_error, error)
    end

    # @example listening to this event
    #   session.on(:private_session_mode_changed) do |enabled|
    #     if enabled
    #       puts "Private session enabled!"
    #     else
    #       puts "Private session disabled!"
    #     end
    #   end
    #
    # @yield
    def private_session_mode_changed_callback(pointer, enabled)
      trigger(pointer, :private_session_mode_changed, enabled)
    end
  end
end
