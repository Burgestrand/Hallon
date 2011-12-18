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

      # Rename the folder.
      #
      # @note libspotify has no actual folder rename; what happens is that
      #       the folder is removed and then re-created at the same position.
      # @param [#to_s] new_name
      # @return [Folder] the new folder
      def rename(new_name)
        raise IndexError, "playlist has moved from #{@begin}..#{@end}" if moved?

        insert_at = @begin
        container.remove(@begin)
        container.insert_folder(insert_at, new_name)
        container.move(insert_at + 1, @end)
      end

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

      # @return [Boolean] true if the folder has moved.
      def moved?
        Spotify.playlistcontainer_playlist_folder_id(container.pointer, @begin) != id or
        Spotify.playlistcontainer_playlist_folder_id(container.pointer, @end) != id
      end
    end

    extend Observable::PlaylistContainer

    # Wrap an existing PlaylistContainer pointer in an object.
    #
    # @param [Spotify::Pointer] pointer
    def initialize(pointer)
      @pointer = to_pointer(pointer, :playlistcontainer)

      subscribe_for_callbacks do |callbacks|
        Spotify.playlistcontainer_remove_callbacks(pointer, callbacks, nil)
        Spotify.playlistcontainer_add_callbacks(pointer, callbacks, nil)
      end
    end

    # @return [Boolean] true if the container is loaded.
    def loaded?
      Spotify.playlistcontainer_is_loaded(pointer)
    end

    # @return [User, nil] owner of the container (nil if unknown or no owner).
    def owner
      owner = Spotify.playlistcontainer_owner!(pointer)
      User.from(owner)
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

      Playlist.from(playlist)
    end

    # Create a new folder with the given name at the end of the container.
    #
    # @param [String] name
    # @return [Folder]
    # @raise [Error] if the operation failed
    # @see #insert_folder
    def add_folder(name)
      insert_folder(size, name)
    end

    # Create a new folder with the given name at the specified index.
    #
    # @param [Integer] index
    # @param [String] name
    # @raise [Error] if the operation failed
    def insert_folder(index, name)
      error = Spotify.playlistcontainer_add_folder(pointer, index, name.to_s)
      Error.maybe_raise(error)
      contents[index]
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
    # @example an illustration of how contents are moved
    #   # given a container like this:
    #   # A, B, C, D
    #
    #   container.move(0, 1)
    #     # => B, A, C, D
    #
    #   container.move(0, 3)
    #     # => B, C, D, A
    #
    #   container.move(3, 1)
    #     # => A, D, B, C
    #
    # @note If moving a folder, only that end of the folder is moved. The folder
    #       size will change!
    # @param [Integer] from index to move from
    # @param [Integer] to index the item will end up at
    # @return [Playlist, Folder] the entity that was moved
    # @raise [Error] if the operation failed
    def move(from, to)
      error = move_playlist(from, to, false)
      Error.maybe_raise(error)
      contents[to]
    end

    # Control if if the item at index `from` can be moved to `infront_of`.
    #
    # @param (see #move)
    # @return [Boolean] true if the operation can be performed
    def can_move?(from, to)
      error = move_playlist(from, to, true)
      number, symbol = Error.disambiguate(error)
      symbol == :ok
    end

    protected
      # Wrapper for original API; adjusts indices accordingly.
      #
      # @param [Integer] from
      # @param [Integer] from
      # @return [Integer] error
      def move_playlist(from, infront_of, dry_run)
        infront_of += 1 if from < infront_of
        Spotify.playlistcontainer_move_playlist(pointer, from, infront_of, dry_run)
      end

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
  end
end
