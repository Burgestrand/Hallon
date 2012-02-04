# coding: utf-8
module Hallon
  # This is an implementation of a fictionary audio driver for Hallon. Each method is
  # documented with expectations, parameters and other details. This class should serve
  # as a guide on how to write your own audio driver with Hallon.
  #
  # @note this class is not used by Hallon, and is only here for documentation purposes.
  class ExampleAudioDriver
    # Here you can do your initialization of your audio driver. No
    # parameters are given, and at this point no information of the
    # audio format (or similar) is given.
    def initialize
    end

    # Called when the audio playback should start. ie. when buffered
    # audio previously retrieved from #stream should start blasting
    # from the speakers.
    #
    # This method is only called as a direct result of the libspotify
    # `start_playback` callback. It is recommended for this method to
    # be thread-safe.
    #
    # Once called, audio playback is expected continue until either
    # {#pause} or {#stop} is called.
    #
    # It is very important that this method does not block!
    #
    # Return value is ignored.
    def play
    end

    # Called when the audio playback should be paused; often this is
    # called as a direct result of {Player#pause}.
    #
    # It may also be called if the audio is stuttering, to allow spotify
    # to buffer up more data before continuing playback. Because of this,
    # this method is recommended to be thread-safe.
    #
    # It is very important that this method does not block!
    #
    # Return value is ignored.
    def pause
    end

    # Called when audio playback should be stopped. Audio buffers can
    # be cleared and any grip around the users’ speakers should also
    # be released.
    #
    # This is only ever called as a direct result of the user manually
    # stopping the player with {Player#stop}.
    #
    # Return value is ignored.
    def stop
    end

    # Sets the current audio format.
    #
    # This is only ever called from inside the block given to {#stream}. It
    # should be safe to recreate any existing audio buffers to fit the new
    # audio format, as no frames will be delivered to the audio driver before
    # this call returns.
    #
    # @note see `Spotify.enum_type(:sampletype).symbols` for a list of possible sample types
    # @param [Hash] new_format
    # @option new_format [Integer] :rate sample rate (eg. 44100)
    # @option new_format [Integer] :channels number of audio channels (eg. 2)
    # @option new_format [Symbol] :type sample type (eg. :int16)
    def format=(new_format)
      @format = new_format
    end

    # This method is expected to return the currently set format, which
    # has been previously set by {#format=}.
    #
    # The player will only ever call this after previously setting the
    # format through {#format=}.
    #
    # It is important that this always returns the same value that was
    # given to {#format=}!
    def format
      @format
    end

    # Called *once* by the player, to initiate audio streaming to this driver.
    # This method is expected to run indefinitely, and is run inside a separate
    # thread.
    #
    # It is given a block that takes an integer as an argument, which specifies
    # how many audio frames the player may give the driver for audio playback.
    # If the block is given no arguments, the audio driver is expected to be able
    # to consume any number of audio frames for the given call.
    #
    # When the audio driver is ready to consume audio, it should yield to the given
    # block. If it can take only a finite number of audio frames it should be specified
    # in the parameter.
    #
    # Upon yielding to the given block, the player will:
    #
    # - if the player is currently not playing, wait until it is
    # - inspect the format of the audio driver
    # - if the format has changed, set the new format on the driver __and return nil__
    # - if the format has not changed, return an array of audio frames
    #
    # The number of frames returned upon yielding will be less than or equal to
    # the number of frames requested when calling yield.
    #
    # The format of the audio frames can be determined by inspecting {#format} once
    # the yield has returned. It is safe to inspect this format at any point within
    # this method.
    #
    # The audio frames is a ruby array, grouped by channels. So for 2-channeled audio
    # the returned array from a yield will look similar to this:
    #
    #     [[1239857, -123087], [34971, 123084], …]
    #
    # Also see the implementation for this method on a more concise explanation.
    #
    # @yield [num_frames] to retrieve audio frames for playback buffering
    # @yieldparam [Integer] num_frames maximum number of frames that should be returned
    # @yieldreturn [Array<[]>, nil] an array of audio frames, or nil if audio format has changed
    def stream
      loop do
        # set up internal buffers for current @format
        loop do
          # calculate size of internal buffers
          audio_data = yield(4048) # can only take 4048 frames of 2-channeled int16ne data

          if audio_data.nil?
            # audio format has changed, reinitialize buffers
            break
          else
            # playback the audio data
          end
        end
      end
    end
  end
end
