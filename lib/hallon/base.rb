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

    # Default string representation of self.
    def to_s
      name    = self.class.name
      address = pointer.address.to_s(16)
      "<#{name} address=0x#{address}>"
    end

    private
      # @macro [attach] to_link
      #   @method to_link
      #   @scope  instance
      #   @return [Hallon::Link] {Link} for the current object.
      def self.to_link(cmethod)
        # this is here to work around a YARD limitation, see
        # {Linkable} for the actual source
      end

      # @macro [attach] from_link
      #   @method from_link
      #   @scope  instance
      #   @visibility private
      #   @param  [String, Hallon::Link, Spotify::Pointer] link
      #   @return [Spotify::Pointer] pointer representation of given link.
      def self.from_link(as_object, &block)
        # this is here to work around a YARD limitation, see
        # {Linkable} for the actual source
      end

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
