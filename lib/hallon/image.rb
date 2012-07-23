# coding: utf-8
module Hallon
  # Images are JPEG images that can be linked to and saved.
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__image.html
  class Image < Base
    include Linkable

    from_link :as_image do |link|
      Spotify.image_create_from_link(session.pointer, link)
    end

    to_link :from_image

    extend Observable::Image
    include Loadable

    # A list of available image sizes.
    #
    # @see Album#cover
    # @see Artist#portrait
    def self.sizes
      Spotify.enum_type(:image_size).symbols
    end

    # Create a new instance of an Image.
    #
    # @example from a link
    #   image = Hallon::Image.new("spotify:image:3ad93423add99766e02d563605c6e76ed2b0e450")
    #
    # @example from an image id
    #   image = Hallon::Image.new("3ad93423add99766e02d563605c6e76ed2b0e450")
    #
    # @param [String, Link, Spotify::Image] link link or image id
    def initialize(link)
      if link.respond_to?(:=~) and link =~ %r~(?:image[:/]|\A)([a-fA-F0-9]{40})\z~
        link = to_id($1)
      end

      @pointer = to_pointer(link, Spotify::Image) do
        Spotify.image_create(session.pointer, link)
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

    # @see raw_id
    # @return [String] image ID as a sequence of hexadecimal digits.
    def id
      to_hex(raw_id)
    end

    # @see id
    # @return [String] image ID as a binary string.
    def raw_id
      Spotify.image_image_id(pointer)
    end

    # @return [String] raw image data as a binary encoded string.
    def data
      FFI::MemoryPointer.new(:size_t) do |size|
        data = Spotify.image_data(pointer, size)
        size = size.read_size_t

        if size > 0
          return data.read_bytes(size)
        else
          return "".force_encoding("BINARY")
        end
      end
    end

    # Overridden to first and foremost compare by id if applicable.
    #
    # @param [Object] other
    # @return [Boolean]
    def ==(other)
      super or if other.is_a?(Image)
        raw_id == other.raw_id
      end
    end

    protected
      # @see to_id
      # @param [String] id an image id as a binary string
      # @return [String] image id as a hexadecimal string
      def to_hex(id)
        id.unpack('H40')[0]
      end

      # @see to_hex
      # @param [String] hex an image id as a hexadecimal string
      # @return [String] image id as a binary string
      def to_id(hex)
        [hex].pack('H40')
      end
  end
end
