# coding: utf-8
module Hallon
  # Hallon::Enumerator is like a lazy Array.
  #
  # It provides methods from Enumerable to enumerate through its’ contents,
  # size information and Array access methods. It’s used throughout Hallon
  # for collections of items such as artist tracks, albums and so on.
  class Enumerator
    include Enumerable

    # @return [Spotify::Pointer]
    attr_reader :pointer

    # @macro [attach] size
    #   @method size
    #   @return [Integer] size of this enumerator
    #
    # @param [String, Symbol] method
    def self.size(method)
      # this method is about twice as fast as define_method/public_send
      class_eval <<-SIZE, __FILE__, __LINE__ + 1
        def size
          Spotify.#{method}(pointer)
        end
      SIZE
    end

    # @example modifying result with a block
    #   item :playlist_track! do |track|
    #     Track.from(track)
    #   end
    #
    # @note block passed is used to modify return value from Spotify#item_method
    # @param [Symbol, String] method
    # @yield [item, index, pointer] item from calling Spotify#item_method
    # @yieldparam item
    # @yieldparam [Integer] index
    # @yieldparam [Spotify::Pointer] pointer
    #
    # @macro [attach] item
    #   @method at(index)
    def self.item(method, &block)
      define_method(:at) do |index|
        item = Spotify.public_send(method, pointer, index)
        item = instance_exec(item, index, pointer, &block) if block_given?
        item
      end
    end

    # initialize the enumerator with `subject`.
    #
    # @param [#pointer] subject
    def initialize(subject)
      @pointer = subject.pointer
    end

    # Yield each item out of the enumerator.
    #
    # @yield obj
    # @return [Enumerator] self
    def each
      size.times { |i| yield(self[i]) }
      self
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
      # crazy inefficient, but also crazy easy, don’t hate me :(
      items  = [*0...size]
      result = items[*args]

      if result.nil?
        nil
      elsif result.respond_to?(:map)
        result.map { |index| at(index) }
      else
        at(result)
      end
    end

    # @return [String] String representation of the Enumerator.
    def to_s
      "<#{self.class.name}:0x#{object_id.to_s(16)} @size=#{size}>"
    end
  end
end
