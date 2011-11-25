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

      callbacks = Spotify::PlaylistContainerCallbacks.create(self, @sp_callbacs = {})
      Spotify.playlistcontainer_add_callbacks(pointer, callbacks, nil)
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

    # Add the given playlist to the end of the container.
    #
    # If the given `name` is a valid spotify playlist URI, Hallon will add
    # the existing playlist to the container. To always create a new playlist,
    # set `force_create` to true.
    #
    # @example create a new playlist
    #   container.add "New playlist"
    #
    # @example create a new playlist even if it’s a valid playlist URI
    #   container.add "spotify:user:burgestrand:playlist:07AX9IY9Hqmj1RqltcG0fi", force: true
    #
    # @example add existing playlist
    #   playlist = container.add "spotify:user:burgestrand:playlist:07AX9IY9Hqmj1RqltcG0fi"
    #
    #   playlist = Hallon::Playlist.new("spotify:user:burgestrand:playlist:07AX9IY9Hqmj1RqltcG0fi")
    #   container.add playlist
    #
    #   link = Hallon::Link.new("spotify:user:burgestrand:playlist:07AX9IY9Hqmj1RqltcG0fi")
    #   playlist = container.add link
    #
    # @param [String, Playlist, Link] playlist
    # @param [Boolean] force_create force creation of a new playlist
    # @return [Playlist, nil] the added playlist, or nil if the operation failed
    def add(name, force_create = false)
      playlist = if name.is_a?(String) and not Link.valid?(name) or force_create
        Spotify.playlistcontainer_add_new_playlist!(pointer, name)
      else
        link = Link.new(name)
        Spotify.playlistcontainer_add_playlist!(pointer, link.pointer)
      end

      Playlist.new(playlist) unless playlist.null?
    end

    # playlistcontainer_playlist_folder_name
    # playlistcontainer_playlist_folder_id
    # playlistcontainer_remove_playlist
    # playlistcontainer_move_playlist
    # playlistcontainer_add_folder
  end
end
