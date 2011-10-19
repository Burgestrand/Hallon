# coding: utf-8
module Hallon
  # Users are the entities that interact with the Spotify service.
  #
  # Methods are available for retrieving metadata and relationship
  # status between users.
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__user.html
  class User < Base
    extend Linkable

    # @macro [attach] from_link
    #   Given a Link, get its’ underlying pointer.
    #
    #   @method to_link
    #   @scope  instance
    #   @param  [String, Hallon::Link, FFI::Pointer] link
    #   @return [FFI::Pointer]
    from_link :profile do |link|
      Spotify.link_as_user!(link)
    end

    # @macro [attach] to_link
    #   Create a Link to the current object.
    #
    #   @method to_link
    #   @scope  instance
    #   @return [Hallon::Link]
    to_link :from_user

    # Construct a new instance of User.
    #
    # @param [String, Link, Spotify::Pointer] link
    def initialize(link)
      @pointer = to_pointer(link, :user)
    end

    # @return [Boolean] true if the user is loaded
    def loaded?
      Spotify.user_is_loaded(@pointer)
    end

    # Retrieve the name of the current user.
    #
    # @note Unless the user is {User#loaded?} only the canonical name is accessible
    # @param [Symbol] type one of :canonical, :display, :full
    # @return [String]
    def name(type = :canonical)
      case type
      when :display
        Spotify.user_display_name(@pointer)
      when :full
        Spotify.user_full_name(@pointer)
      when :canonical
        Spotify.user_canonical_name(@pointer)
      else
        raise ArgumentError, "expected type to be :display, :full or :canonical, but was #{type}"
      end.to_s
    end

    # Retrieve the URL to the users’ profile picture.
    #
    # @return [String]
    def picture
      Spotify.user_picture(@pointer).to_s
    end
  end
end
