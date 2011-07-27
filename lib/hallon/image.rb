# coding: utf-8
module Hallon
  # Images are JPEG images that can be linked to and saved.
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__image.html
  class Image < Base
    extend Linkable

    from_link :as_image do |link, session|
      Spotify::image_create_from_link(session, link)
    end

    to_link :from_image

    # Image triggers `:load` when loaded
    include Hallon::Observable

    # Create a new instance of an Image.
    #
    # @param [String, Link, FFI::Pointer] link link or image id
    # @param [Hallon::Session] session
    def initialize(link, session = Session.instance)
      if link.is_a?(String)
        link = to_id($1) if link =~ %r|image[:/](\h{40})|

        FFI::MemoryPointer.new(:char, 20) do |ptr|
          ptr.write_bytes link
          link = Spotify.image_create(session.pointer, ptr)
        end
      else
        link = from_link(link, session.pointer)
      end

      @pointer = Spotify::Pointer.new link, :image

      @callback = proc { trigger(:load) }
      Spotify::image_add_load_callback(@pointer, @callback, nil)

      # TODO: remove load_callback when @pointer is released
      # TODO: this makes libspotify segfault, figure out why
      # on(:load) { Spotify::image_remove_load_callback(@pointer, @callback, nil) }
    end

    # True if the image has been loaded.
    #
    # @return [Boolean]
    def loaded?
      Spotify::image_is_loaded(@pointer)
    end

    # Retrieve the current error status.
    #
    # @return [Symbol] error
    def status
      Spotify::image_error(@pointer)
    end

    # Retrieve image format.
    #
    # @return [Symbol] `:jpeg` or `:unknown`
    def format
      Spotify::image_format(@pointer)
    end

    # Retrieve image ID as a string.
    #
    # @param [Boolean] raw true if you want the image id as a hexadecimal string
    # @return [String]
    def id(raw = false)
      id = Spotify::image_image_id(@pointer).read_string(20)
      raw ? id : to_hex(id)
    end

    # Raw image data as a binary encoded string.
    #
    # @return [String]
    def data
      FFI::MemoryPointer.new(:size_t) do |size|
        data = Spotify::image_data(@pointer, size)
        return data.read_bytes(size.read_size_t)
      end
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
