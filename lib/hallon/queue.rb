# coding: utf-8
require 'thread'

module Hallon
  # Hallon::Queue is a non-blocking (well, not entirely) sized FIFO queue.
  #
  # You initialize the queue with a `max_size`, and then push data to it.
  # For every push operation, the Queue will tell you how much of your data
  # it could consume. If the queue becomes full, it won’t accept any more
  # data (and will return 0 on the #push operation) until you pull some data
  # out of it with #pop.
  #
  # Hallon::Queue is useful for handling {Hallon::Observable::Session#music_delivery_callback}.
  #
  # @example
  #   queue = Hallon::Queue.new(4)
  #   queue.push([1, 2]) # => 2
  #   queue.push([3]) # => 1
  #   queue.push([4, 5, 6]) # => 1
  #   queue.push([5, 6]) # => 0
  #   queue.pop(1) # => [1]
  #   queue.push([5, 6]) # => 1
  #   queue.pop # => [2, 3, 4, 5]
  class Queue
    attr_reader :max_size

    # @param [Integer] max_size
    def initialize(max_size)
      @mutex    = Mutex.new
      @condv    = ConditionVariable.new

      @max_size = max_size
      @samples  = []
    end

    # @param [#take] data
    # @return [Integer] how much of the data that was added to the queue
    def push(samples)
      synchronize do
        can_accept  = max_size - size
        new_samples = samples.take(can_accept)

        @samples.concat(new_samples)
        @condv.signal

        new_samples.size
      end
    end

    # @note If the queue is empty, this operation will block until data is available.
    # @param [Integer] num_samples max number of samples to pop off the queue
    # @return [Array] data, where data.size might be less than num_samples but never more
    def pop(num_samples = max_size)
      synchronize do
        @condv.wait(@mutex) while @samples.empty?
        @samples.shift(num_samples)
      end
    end

    # @return [Integer] number of samples in buffer
    def size
      @samples.size
    end

    private
      def synchronize
        @mutex.synchronize { return yield }
      end
  end
end
