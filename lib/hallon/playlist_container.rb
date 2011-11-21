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

    # @overload add(name)
    #   Create a new playlist at the end of the container with the given name.
    #
    #   @param [String] name
    #   @return [Playlist, nil] the new playlist, or nil if the operation failed
    #
    # @overload add(playlist)
    #   Add the given playlist to the end of the container.
    #
    #   @param [Playlist, Link, #to_link] playlist
    #   @return [Playlist, nil] the added playlist, or nil if the operation failed
    def add(name_or_playlist)
      playlist = if name_or_playlist.is_a?(String)
        Spotify.playlistcontainer_add_new_playlist!(pointer, name_or_playlist)
      else
        link = name_or_playlist
        link = link.to_link unless link.is_a?(Link)
        Spotify.playlistcontainer_add_playlist!(pointer, link.pointer)
      end

      Playlist.new(playlist) unless playlist.null?
    end
  end
end
