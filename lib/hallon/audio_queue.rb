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
  # @example
  #   queue = Hallon::AudioQueue.new(4)
  #   queue.push([1, 2]) # => 2
  #   queue.push([3]) # => 1
  #   queue.push([4, 5, 6]) # => 1
  #   queue.push([5, 6]) # => 0
  #   queue.pop(1) # => [1]
  #   queue.push([5, 6]) # => 1
  #   queue.pop # => [2, 3, 4, 5]
  #
  # @private
  class AudioQueue
    attr_reader :max_size

    # @param [Integer] max_size
    def initialize(max_size)
      @max_size = max_size
      @samples  = []

      @samples.extend(MonitorMixin)
      @condvar  = @samples.new_cond
    end

    # @param [#take] data
    # @return [Integer] how much of the data that was added to the queue
    def push(samples)
      synchronize do
        can_accept  = max_size - size
        new_samples = samples.take(can_accept)

        @samples.concat(new_samples)
        @condvar.signal

        new_samples.size
      end
    end

    # @note If the queue is empty, this operation will block until data is available.
    # @param [Integer] num_samples max number of samples to pop off the queue
    # @return [Array] data, where data.size might be less than num_samples but never more
    def pop(num_samples = max_size)
      synchronize do
        @condvar.wait_while { empty? }
        @samples.shift(num_samples)
      end
    end

    # @return [Integer] number of samples in buffer.
    def size
      synchronize { @samples.size }
    end

    # @return [Boolean] true if the queue has a {#size} of 0.
    def empty?
      size.zero?
    end

    # Clear all data from the AudioQueue.
    def clear
      synchronize { @samples.clear }
    end

    # Use this if you wish to perform multiple operations on
    # the AudioQueue atomicly.
    #
    # @note this lock is re-entrant, you can nest it in itself
    # @yield exclusive section around the queue contents
    # @return whatever the given block returns
    def synchronize
      @samples.synchronize { return yield }
    end
  end
end
