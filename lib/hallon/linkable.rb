# coding: utf-8
module Hallon
  # Methods shared between objects that can be created from Spotify URIs,
  # or can be turned into Spotify URIs.
  #
  # @note Linkable is not part of Hallons’ public API.
  # @private
  module Linkable
    # These are extended onto a class when {Linkable} is included.
    include Forwardable

    # Creates `from_link` class & instance method which’ll convert a link to a pointer
    #
    # @example
    #   # Creates instance method `from_link(link)`
    #   from_link(:playlist) { |link| Spotify::link_as_playlist(link) }
    #
    # @param [Symbol] type expected link type
    # @yield [link, *args] called when conversion is needed from Link pointer
    # @yieldparam [Hallon::Link] link
    # @yieldparam *args any extra arguments given to `#from_link`
    # @see Link#pointer
    def from_link(type)
      define_singleton_method(:from_link) do |link, *args|
        if link.is_a? FFI::Pointer then link else
          yield Link.new(link).pointer(type), *args
        end
      end

      def_delegators 'self.class', :from_link
    end

    # Defines `to_link` class & instance method.
    #
    # @example
    #   to_link(:artist)
    #
    # @note Calls down to `Spotify::link_create_from_#{type}(@pointer)`
    # @param [Symbol] type object kind
    # @return [Link]
    def to_link(type)
      define_singleton_method(:to_link) do |ptr, *args|
        link = Spotify.__send__(:"link_create_from_#{type}", ptr, *args)
        Hallon::Link.new(link)
      end

      define_method(:to_link) do |*args, &block|
        self.class.to_link(@pointer, *args, &block)
      end
    end
  end
end
