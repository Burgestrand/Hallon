# coding: utf-8
module Hallon
  # Methods shared between objects that can be created from Spotify URIs,
  # or can be turned into Spotify URIs.
  #
  # @note Linkable is part of Hallons’ private API. You probably do not
  #       not need to care about these methods.
  #
  # @private
  module Linkable
    # Defines `#from_link`, used in converting a link to a pointer. You
    # can either pass it a `method_name`, or a `type` and a block.
    #
    # @overload from_link(method_name)
    #   Define `#from_link` simply by giving the name of the method,
    #   minus the `link_` prefix.
    #
    #   @example
    #     class Album
    #       extend Linkable
    #
    #       from_link :as_album # => Spotify.link_as_album(pointer, *args)
    #       # ^ is roughly equivalent to:
    #       def from_link(link, *args)
    #         unless Spotify::Pointer.typechecks?(link, :link)
    #           link = Link.new(link).pointer(:album)
    #         end
    #
    #         Spotify.link_as_album!(link)
    #       end
    #     end
    #
    #   @param [Symbol] method_name
    #
    # @overload from_link(type) { |*args| … }
    #   Define `#from_link` to use the given block to convert an object
    #   from a link. The link is converted to a pointer and typechecked
    #   to be of the same type as `type` before given to the block.
    #
    #   @example
    #     class User
    #       extend Linkable
    #
    #       from_link :profile do |pointer|
    #         Spotify.link_as_user!(pointer)
    #       end
    #       # ^ is roughly equivalent to:
    #       def from_link(link, *args)
    #         unless Spotify::Pointer.typechecks?(link, :link)
    #           link = Link.new(link).pointer(:profile)
    #         end
    #
    #         Spotify.link_as_user!(link)
    #       end
    #     end
    #
    #   @param [#to_s] type link type
    #   @yield [link, *args] called when conversion is needed from Link pointer
    #   @yieldparam [Spotify::Pointer] link
    #   @yieldparam *args any extra arguments given to `#from_link`
    #
    # @note Private API. You probably do not need to care about this method.
    def from_link(as_object, &block)
      block ||= Spotify.method(:"link_#{as_object}!")
      type    = as_object.to_s[/^(as_)?([^_]+)/, 2].to_sym

      define_method(:from_link) do |link, *args|
        if link.is_a?(FFI::Pointer) and not link.is_a?(Spotify::Pointer)
          link
        else
          unless Spotify::Pointer.typechecks?(link, :link)
            link = Link.new(link).pointer(type)
          end

          instance_exec(link, *args, &block)
        end
      end
    end

    # Defines `#to_link` method, used in converting the object to a {Link}.
    #
    # @example
    #   class Artist
    #     extend Linkable
    #
    #     to_link :from_artist
    #     # ^ is the same as:
    #     def to_link(*args)
    #       link = Spotify.link_create_from_artist!(pointer, *args)
    #       Link.new(link)
    #     end
    #   end
    #
    # @param [Symbol] cmethod name of the C method, say `from_artist` in `Spotify.link_create_from_artist`.
    # @return [Link]
    def to_link(cmethod)
      define_method(:to_link) do |*args|
        link = Spotify.__send__(:"link_create_#{cmethod}!", pointer, *args)
        Link.new(link)
      end
    end

    private :from_link
    private :to_link
  end
end
