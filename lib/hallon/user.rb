# coding: utf-8
module Hallon
  # Users are the entities that interact with the Spotify service.
  #
  # Methods are available for retrieving metadata and relationship
  # status between users.
  class User
    private_class_method :new

    # Construct a new instance of User.
    #
    # @note Currently you cannot construct users yourself, use {Session#user}
    # @private
    def initialize(user)
      @pointer = Spotify::Pointer.new(user, :user)
      Spotify::user_add_ref(@pointer)
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
  end
end
