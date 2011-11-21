# coding: utf-8
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

    # @return [Boolean] true if the container is loaded.
    def loaded?
      Spotify.playlistcontainer_is_loaded(pointer)
    end

    # @return [User, nil] owner of the container (nil if unknown or no owner).
    def owner
      owner = Spotify.playlistcontainer_owner!(pointer)
      User.new(owner) unless owner.null?
    end

    # @return [Integer] number of playlists and folders in this container.
    def size
      Spotify.playlistcontainer_num_playlists(pointer)
    end

    # @return [Enumerator<Playlist, Folder, nil>] an enumerator of folders and playlists.
    def contents
      Enumerator.new(size) do |i|
        type = Spotify.playlistcontainer_playlist_type(pointer, i)

        case type
        when :playlist
          playlist = Spotify.playlistcontainer_playlist!(pointer, i)
          Playlist.new(playlist)
        when :start_folder
        when :end_folder
        else # :unknown
        end
      end
    end
  end
end
