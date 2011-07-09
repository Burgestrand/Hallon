# coding: utf-8
module Hallon
  # Methods shared between objects that can be created from Spotify URIs,
  # or can be turned into Spotify URIs.
  #
  # @note Linkable is not part of Hallons’ public API.
  # @private
  module Linkable
    # These are extended onto a class when {Linkable} is included.
    module ClassMethods
      include Forwardable

      # Creates `#convert` method which’ll convert a link to a pointer
      #
      # @example
      #   # Creates instance method `convert(link)`
      #   link_converter(:playlist) do |link|
      #     Spotify::link_as_playlist(link)
      #   end
      #
      # @param [Symbol] type expected link type
      # @yield [link, *args] called when conversion is needed from Link to Pointer
      # @yieldparam [Hallon::Link] link
      # @yieldparam *args any extra arguments given to `#convert`
      # @see Link#pointer
      def link_converter(type)
        define_singleton_method(:convert) do |link, *args|
          if link.is_a? FFI::Pointer then link else
            yield Link.new(link).pointer(type), *args
          end
        end

        def_delegators 'self.class', :convert
      end
    end

    # When included, Linkable also defines the {ClassMethods#link_converter} method.
    def self.included(other)
      other.instance_eval do
        private
          extend ClassMethods
      end
    end

    # Underlying Spotify pointer.
    #
    # @return [FFI::Pointer]
    attr_reader :pointer
  end
end
