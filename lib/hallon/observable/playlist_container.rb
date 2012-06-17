module Hallon::Observable
  # Callbacks related to {Hallon::PlaylistContainer} objects.
  module PlaylistContainer
    # Includes {Hallon::Observable} for you.
    def self.extended(other)
      other.send(:include, Hallon::Observable)
    end

    protected

    # @return [Spotify::PlaylistContainerCallbacks]
    def initialize_callbacks
      struct = Spotify::PlaylistContainerCallbacks.new
      struct.members.each do |member|
        struct[member] = callback_for(member)
      end
      struct
    end

    # @example listening to this event
    #   playlist_container.on(:playlist_added) do |playlist, position, container|
    #     puts playlist.name + " added at #{position}."
    #   end
    #
    # @yield [playlist, position] playlist_added
    # @yieldparam [Playlist] playlist
    # @yieldparam [Integer] position
    def playlist_added_callback(pointer, playlist, position, userdata)
      trigger(pointer, :playlist_added, playlist_from(playlist), position)
    end

    # @example listening to this event
    #   playlist_container.on(:playlist_removed) do |playlist, position, container|
    #     puts playlist.name + " removed from #{position}."
    #   end
    #
    # @yield [playlist, position] playlist_removed
    # @yieldparam [Playlist] playlist
    # @yieldparam [Integer] position
    def playlist_removed_callback(pointer, playlist, position, userdata)
      trigger(pointer, :playlist_removed, playlist_from(playlist), position)
    end

    # @example listening to this event
    #   playlist_container.on(:playlist_moved) do |playlist, position, new_position, container|
    #     puts "moved #{playlist.name} from #{position} to #{new_position}"
    #   end
    #
    # @yield [playlist, position, new_position] playlist_moved
    # @yieldparam [Playlist] playlist
    # @yieldparam [Integer] position
    # @yieldparam [Integer] new_position
    def playlist_moved_callback(pointer, playlist, position, new_position, userdata)
      trigger(pointer, :playlist_moved, playlist_from(playlist), position, new_position)
    end

    # @example listening to this event
    #   playlist_container.on(:container_loaded) do |container|
    #     puts "#{container.owner.name}s container loaded!"
    #   end
    #
    # @yield [] container_loaded
    def container_loaded_callback(pointer, userdata)
      trigger(pointer, :container_loaded)
    end

    protected

      # @param [Spotify::Pointer] playlist
      # @return [Hallon::Playlist] a playlist for the given pointer.
      def playlist_from(playlist)
        pointer = Spotify::Pointer.new(playlist, :playlist, true)
        Hallon::Playlist.new(pointer)
      end
  end
end
