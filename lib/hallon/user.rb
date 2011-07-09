# coding: utf-8
module Hallon
  # Users are the entities that interact with the Spotify service.
  #
  # Methods are available for retrieving metadata and relationship
  # status between users.
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__user.html
  class User
    extend Linkable

    link_converter(:profile) do |link|
      Spotify::link_as_user(link)
    end

    # Construct a new instance of User.
    #
    # @param [String, Link, FFI::Pointer] link
    def initialize(link)
      @pointer = Spotify::Pointer.new convert(link), :user, true
    end

    # @return [Boolean] true if the user is loaded
    def loaded?
      Spotify::user_is_loaded(@pointer)
    end

    # Retrieve the name of the current user.
    #
    # @note Unless the user is {User#loaded?} only the canonical name is accessible
    # @param [Symbol] type one of :canonical, :display, :full
    # @return [String]
    def name(type = :canonical)
      case type
      when :display
        Spotify::user_display_name(@pointer)
      when :full
        Spotify::user_full_name(@pointer)
      when :canonical
        Spotify::user_canonical_name(@pointer)
      else
        raise ArgumentError, "expected type to be :display, :full or :canonical, but was #{type}"
      end.to_s
    end

    # Retrieve the URL to the users’ profile picture.
    #
    # @return [String]
    def picture
      Spotify::user_picture(@pointer).to_s
    end

    # Convert the user to a Spotify URI.
    #
    # @return [Hallon::Link]
    def to_link
      Hallon::Link.new Spotify::link_create_from_user(@pointer)
    end
  end
end
