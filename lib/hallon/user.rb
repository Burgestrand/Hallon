# coding: utf-8
module Hallon
  # Users are the entities that interact with the Spotify service.
  #
  # Methods are available for retrieving metadata and relationship
  # status between users.
  class User
    # Construct a new instance of User.
    #
    # @param [String, Link, FFI::Pointer] link
    def initialize(link)
      @pointer = Spotify::Pointer.new from_link(link), :user, true
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
      method = :"user_#{type}_name"
      Spotify::public_send(method, @pointer).to_s
    end

    # Retrieve the URL to the users’ profile picture.
    #
    # @return [String]
    def picture
      Spotify::user_picture(@pointer).to_s
    end

    private
      def from_link(link)
        if link.is_a? FFI::Pointer then link else
          Spotify::link_as_user Link.new(link).pointer(:profile)
        end
      end
  end
end
