module Hallon
  class Enumerator
    include Enumerable

    # @return [Integer] number of items this enumerator can yield
    attr_reader :size

    # Construct an enumerator of `size` elements.
    #
    # @param [Integer] size
    # @yield to the given block when an item is requested (through #each, #[] etc)
    # @yieldparam [Integer] index item to retrieve
    def initialize(size, &yielder)
      @size  = size
      @items = Array.new(size) do |i|
        lambda { yielder[i] }
      end
    end

    # Yield each item out of the enumerator.
    #
    # @yield obj
    # @return [Enumerator]
    def each
      tap do
        size.times { |i| yield(self[i]) }
      end
    end

    # @overload [](index)
    #   @return [Object, nil]
    #
    # @overload [](start, length)
    #   @return [Array, nil]
    #
    # @overload [](range)
    #   @return [Array, nil]
    #
    # Works exactly the same as Array#[], including the special cases.
    #
    # @see http://rdoc.info/stdlib/core/1.9.2/Array:[]
    def [](*args)
      result = @items[*args]

      if result.nil?
        nil
      elsif result.respond_to?(:map)
        result.map(&:call)
      else
        result.call
      end
    end
  end
end
