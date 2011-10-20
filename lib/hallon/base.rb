# coding: utf-8
module Hallon
  # All objects in Hallon are mere representations of Spotify objects.
  # Hallon::Base covers basic functionality shared by all of these.
  class Base
    # Underlying FFI pointer.
    #
    # @return [FFI::Pointer]
    attr_reader :pointer

    # True if both objects represent the *same* object.
    #
    # @param [Object] other
    # @return [Boolean]
    def ==(other)
      pointer == other.pointer
    rescue NoMethodError
      super
    end

    private
      # The current Session instance.
      #
      # @return [Session]
      def session
        Session.instance
      end

      # Convert a given object to a pointer by best of ability.
      #
      # @param [Spotify::Pointer, String, Link] resource
      # @return [Spotify::Pointer]
      # @raise [TypeError] when pointer could not be created, or null
      def to_pointer(resource, type, *args)
        if resource.is_a?(FFI::Pointer) and not resource.is_a?(Spotify::Pointer)
          raise TypeError, "Hallon does not support raw FFI::Pointers, wrap it in a Spotify::Pointer"
        end

        pointer = if Spotify::Pointer.typechecks?(resource, type)
          resource
        elsif is_linkable? and Spotify::Pointer.typechecks?(resource, :link)
          from_link(resource, *args)
        elsif is_linkable? and Link.valid?(resource)
          from_link(resource, *args)
        elsif block_given?
          yield(resource, *args)
        end

        if pointer.nil? or pointer.null?
          raise ArgumentError, "#{resource.inspect} is not a valid spotify #{type} URI or pointer"
        elsif not Spotify::Pointer.typechecks?(pointer, type)
          raise TypeError, "“#{resource}” is of type #{resource.type}, #{type} expected"
        else
          pointer
        end
      end

      # @return [Boolean] true if the object can convert links to pointers
      def is_linkable?
        respond_to?(:from_link)
      end
  end
end
