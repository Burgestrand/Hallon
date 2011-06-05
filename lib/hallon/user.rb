module Hallon
  # Users are the entities that interact with the Spotify service.
  #
  # Methods are available for retrieving metadata and relationship
  # status between users.
  class User
    private_class_method :new

    # Conceive a new user from a given FFI::Pointer.
    #
    # @private
    def initialize(user)
      Spotify::user_add_ref(@pointer)
      @pointer = Spotify::Pointer.new(user, :user)
    end

    # True if the user is loaded.
    #
    # @return [Boolean]
    def loaded?
      Spotify::user_is_loaded(@pointer)
    end

    # Retrieve the name of the current user.
    #
    # @note Unless the user is #loaded? only the canonical name is accessible
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
