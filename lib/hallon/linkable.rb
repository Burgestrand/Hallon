module Hallon
  # Methods shared between objects that can be created from Spotify URIs,
  # or can be turned into Spotify URIs.
  #
  # @note Linkable is not part of Hallons’ public API.
  # @private
  module Linkable
    private
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
      # @yield [link] called when conversion is needed from Link to Pointer
      # @yieldparam [Hallon::Link] link
      # @see Link#pointer
      def link_converter(type)
        define_singleton_method(:convert) do |link|
          if link.is_a? FFI::Pointer then link else
            yield Link.new(link).pointer(type)
          end
        end

        def_delegators 'self.class', :convert
      end
  end
end
