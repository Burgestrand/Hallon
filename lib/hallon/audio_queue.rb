# coding: utf-8
require 'monitor'

module Hallon
  # Hallon::AudioQueue is a non-blocking (well, not entirely) sized FIFO queue.
  #
  # You initialize the queue with a `max_size`, and then push data to it.
  # For every push operation, the AudioQueue will tell you how much of your data
  # it could consume. If the queue becomes full, it won’t accept any more
  # data (and will return 0 on the #push operation) until you pull some data
  # out of it with #pop.
  #
  # Hallon::AudioQueue is useful for handling {Hallon::Observable::Session#music_delivery_callback}.
  #
  # @example filling the buffer
  #   queue = Hallon::AudioQueue.new(4)
  #   format = { :rate => 44100, :channels => 2 }
  #   queue.push(format, [1, 2]) # => 2
  #   queue.push(format, [3]) # => 1
  #   queue.push(format, [4, 5, 6]) # => 1
  #   queue.push(format, [5, 6]) # => 0
  #   queue.pop(format, 1) # => [1]
  #   queue.push(format, [5, 6]) # => 1
  #   queue.pop(format) # => [2, 3, 4, 5]
  #
  # @example changing the format
  #   queue  = Hallon::AudioQueue.new(4)
  #   queue.format # => nil
  #   queue.push(:initial_format, [1, 2, 3, 4]) # => 4
  #   queue.size # => 4
  #   queue.format # => :initial_format
  #   queue.push(:new_format, [1, 2]) # => 2
  #   queue.size # => 2
  #   queue.format # => :new_format
  #
  # @private
  class AudioQueue
    attr_reader :max_size

    # @param [Integer] max_size how many frames
    def initialize(max_size)
      @max_size = max_size
      @frames   = []
      @format   = nil

      @frames.extend(MonitorMixin)
      @condvar  = @frames.new_cond
    end

    # @note If the format is not the same as the current format, the queue is
    #       emptied before appending the new data. In this case, {#format} will
    #       be assigned to the new format as well.
    #
    # @param [Hash] format format of the audio frames given
    # @param [#take] frames
    # @return [Integer] how much of the data that was added to the queue
    def push(format, frames)
      synchronize do
        unless format == @format
          @format = format
          clear
        end

        can_accept  = max_size - size
        new_frames = frames.take(can_accept)

        @frames.concat(new_frames)
        @condvar.signal

        new_frames.size
      end
    end

    # @note If the queue is empty, this operation will block until data is available.
    # @note When data is available, if it’s not in the same format as the format requested
    #       the return value will be nil. This is to avoid the format changing during wait.
    #
    # @param [Hash] format requested format
    # @param [Integer] num_frames max number of frames to pop off the queue
    # @return [Array, nil] array of data, but no longer than `num_frames`
    def pop(format, num_frames = max_size)
      synchronize do
        @condvar.wait_while { empty? }
        @frames.shift(num_frames) if format == @format
      end
    end

    # @return [Integer] number of frames in buffer.
    def size
      synchronize { @frames.size }
    end

    # @return [Boolean] true if the queue has a {#size} of 0.
    def empty?
      size.zero?
    end

    # Clear all data from the AudioQueue.
    def clear
      synchronize { @frames.clear }
    end

    # Returns the format previously set by #format=.
    attr_reader :format

    # Use this if you wish to perform multiple operations on
    # the AudioQueue atomicly.
    #
    # @note this lock is re-entrant, you can nest it in itself
    # @yield exclusive section around the queue contents
    # @return whatever the given block returns
    def synchronize
      @frames.synchronize { return yield }
    end

    # Create a condition variable bound to this AudioQueue.
    # Should be used if you want to wait inside {#synchronize}.
    #
    # @return [MonitorMixin::ConditionVariable]
    # @see monitor.rb (ruby stdlib)
    def new_cond
      @frames.new_cond
    end
  end
end
