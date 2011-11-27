# coding: utf-8
module Hallon
  # PlaylistContainers are the objects that hold playlists. Each User
  # in libspotify has a container for its’ starred and published playlists,
  # and every logged in user has its’ own container.
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__playlist.html
  class PlaylistContainer < Base
    # Folders are parts of playlist containers in that they surround playlists
    # with a beginning marker and an ending marker. The playlists between these
    # markers are considered "inside the playlist".
    class Folder
      # @return [PlaylistContainer] playlistcontainer this folder was created from.
      attr_reader :container

      # @return [Integer] index this folder starts at in the container.
      attr_reader :begin

      # @return [Integer] index this folder ends at in the container.
      attr_reader :end

      # @return [Integer]
      attr_reader :id

      # @return [String]
      attr_reader :name

      # @param [PlaylistContainer] container
      # @param [Range] indices
      def initialize(container, indices)
        @container = container
        @begin     = indices.begin
        @end       = indices.end

        @id   = Spotify.playlistcontainer_playlist_folder_id(container.pointer, @begin)
        FFI::Buffer.alloc_out(256) do |buffer|
          error = Spotify.playlistcontainer_playlist_folder_name(container.pointer, @begin, buffer, buffer.size)
          Error.maybe_raise(error) # should not fail, but just to be safe!

          @name = buffer.get_string(0)
        end
      end

      # @param [Folder] other
      # @return [Boolean] true if the two folders are the same (same indices, same id).
      def ==(other)
        !! [:id, :container, :begin, :end].all? do |attr|
          public_send(attr) == other.public_send(attr)
        end if other.is_a?(Folder)
      end
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
        case playlist_type(i)
        when :playlist
          playlist = Spotify.playlistcontainer_playlist!(pointer, i)
          Playlist.new(playlist)
        when :start_folder, :end_folder
          Folder.new(self, folder_range(i))
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
      playlist = if force_create or not Link.valid?(name) and name.is_a?(String)
        Spotify.playlistcontainer_add_new_playlist!(pointer, name.to_s)
      else
        link = Link.new(name)
        Spotify.playlistcontainer_add_playlist!(pointer, link.pointer)
      end

      Playlist.new(playlist) unless playlist.null?
    end

    # Create a new folder with the given name at the end of the container.
    #
    # @param [String] name
    # @return [Folder]
    # @raise [Error] if the operation failed
    def add_folder(name)
      error = Spotify.playlistcontainer_add_folder(pointer, size, name.to_s)
      Error.maybe_raise(error)
      contents[-1]
    end

    # Remove a playlist or a folder (but not its’ contents).
    #
    # @note When removing a folder, both its’ start and end is removed.
    # @param [Integer] index
    # @return [PlaylistContainer]
    # @raise [Error] if the index is out of range
    def remove(index)
      remove = proc { |idx| Spotify.playlistcontainer_remove_playlist(pointer, idx) }

      error = case playlist_type(index)
      when :start_folder, :end_folder
        indices = folder_range(index)

        Error.maybe_raise(remove[indices.begin])
        remove[indices.end - 1] # ^ everything moves down one step
      else
        remove[index]
      end

      tap { Error.maybe_raise(error) }
    end

    # Move a playlist or a folder.
    #
    # @note If moving a folder, only that end of the folder is moved. The folder
    #       size will change!
    #
    # @param [Integer] from
    # @param [Integer] to
    # @param [Boolean] dry_run don’t really move anything (useful to check if it can be moved)
    # @return [Playlist, Folder] the entity that was moved
    # @raise [Error] if the operation failed
    def move(from, to, dry_run = false)
      error = Spotify.playlistcontainer_move_playlist(pointer, from, to, !! dry_run)

      if dry_run
        error, symbol = Error.disambiguate(error)
        symbol == :ok
      else
        Error.maybe_raise(error)
        contents[from > to ? to : to - 1]
      end
    end

    protected
      # Given an index, find out the starting point and ending point
      # of the folder at that index.
      #
      # @param [Integer] index
      # @return [Range] begin..end
      def folder_range(index)
        id      = folder_id(index)
        type    = playlist_type(index)
        same_id = proc { |idx| folder_id(idx) == id }

        case type
        when :start_folder
          beginning = index
          ending    = (index + 1).upto(size - 1).find(&same_id)
        when :end_folder
          ending    = index
          beginning = (index - 1).downto(0).find(&same_id)
        end

        if beginning and ending and beginning != ending
          beginning..ending
        end
      end

      # @return [Symbol] playlist type
      def playlist_type(index)
        Spotify.playlistcontainer_playlist_type(pointer, index)
      end

      # @return [Integer] folder ID of folder at `index`.
      def folder_id(index)
        Spotify.playlistcontainer_playlist_folder_id(pointer, index)
      end

    # playlistcontainer_remove_playlist
    # playlistcontainer_move_playlist
    # playlistcontainer_add_folder (#insert)
  end
end
