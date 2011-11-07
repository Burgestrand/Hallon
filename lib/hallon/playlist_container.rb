module Hallon
  class PlaylistContainer < Base
    class Folder
    end

    include Observable

    # Wrap an existing PlaylistContainer pointer in an object.
    #
    # @param [Spotify::Pointer] pointer
    def initialize(pointer)
      @pointer = to_pointer(pointer, :playlistcontainer)
    end

    # @return [Boolean] true if the container is loaded
    def loaded?
      Spotify.playlistcontainer_is_loaded(pointer)
    end

    # @return [User, nil] owner of the container (nil if unknown or no owner)
    def owner
      owner = Spotify.playlistcontainer_owner!(pointer)
      User.new(owner) unless owner.null?
    end
  end
end
