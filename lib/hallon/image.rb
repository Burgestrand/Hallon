# coding: utf-8
module Hallon
  # Images are JPEG images that can be linked to and saved.
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__image.html
  class Image < Base
    extend Linkable

    from_link :as_image do |link|
      Spotify.image_create_from_link!(session.pointer, link)
    end

    to_link :from_image

    extend Observable::Image

    # Create a new instance of an Image.
    #
    # @example from a link
    #   image = Hallon::Image.new("spotify:image:3ad93423add99766e02d563605c6e76ed2b0e450")
    #
    # @example from an image id
    #   image = Hallon::Image.new("3ad93423add99766e02d563605c6e76ed2b0e450")
    #
    # @param [String, Link, Spotify::Pointer] link link or image id
    def initialize(link)
      if link.respond_to?(:=~) and link =~ %r~(?:image[:/]|\A)([a-fA-F0-9]{40})\z~
        link = to_id($1)
      end

      @pointer = to_pointer(link, :image) do
        ptr = FFI::MemoryPointer.new(:char, 20)
        ptr.write_bytes(link)
        Spotify.image_create!(session.pointer, ptr)
      end

      subscribe_for_callbacks do |callbacks|
        Spotify.image_remove_load_callback(pointer, callbacks, nil)
        Spotify.image_add_load_callback(pointer, callbacks, nil)
      end
    end

    # @return [Boolean] true if the image is loaded.
    def loaded?
      Spotify.image_is_loaded(pointer)
    end

    # @see Error.explain
    # @return [Symbol] image error status.
    def status
      Spotify.image_error(pointer)
    end

    # @return [Symbol] image format, one of `:jpeg` or `:unknown`
    def format
      Spotify.image_format(pointer)
    end

    # @param [Boolean] raw true if you want the image id as a hexadecimal string
    # @return [String] image ID as a string.
    def id(raw = false)
      id = Spotify.image_image_id(pointer).read_string(20)
      raw ? id : to_hex(id)
    end

    # @return [String] raw image data as a binary encoded string.
    def data
      FFI::MemoryPointer.new(:size_t) do |size|
        data = Spotify.image_data(pointer, size)
        return data.read_bytes(size.read_size_t)
      end
    end

    # @see Base#==
    # @param [Object] other
    # @return [Boolean] true if the images are the same object or have the same ID.
    def ==(other)
      super or id(true) == other.id(true)
    rescue NoMethodError, ArgumentError
      false
    end

    protected
      # @param [String]
      # @return [String]
      def to_hex(id)
        id.unpack('H40')[0]
      end

      # @param [String]
      # @return [String]
      def to_id(hex)
        [hex].pack('H40')
      end
  end
end
