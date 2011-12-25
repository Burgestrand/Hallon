module Hallon::Observable
  # Callbacks related to {Hallon::Playlist} objects.
  module Playlist
    # Includes {Hallon::Observable} for you.
    def self.extended(other)
      other.send(:include, Hallon::Observable)
    end

    protected

    # @return [Spotify::PlaylistCallbacks]
    def initialize_callbacks
      struct = Spotify::PlaylistCallbacks.new
      struct.members.each do |member|
        struct[member] = callback_for(member)
      end
      struct
    end

    # @example listening to this event
    #   playlist.on(:tracks_added) do |tracks, position, playlist|
    #     puts "#{tracks.map(&:name).join(', ')} added at #{position} to #{playlist.name}"
    #   end
    #
    # @yield [tracks, position, self] tracks_added
    # @yieldparam [Array<Track>] tracks
    # @yieldparam [Integer] position
    # @yieldparam [Playlist] self
    def tracks_added_callback(pointer, tracks, num_tracks, position, userdata)
      trigger(pointer, :tracks_added, callback_make_tracks(tracks, num_tracks), position)
    end

    # @example listening to this event
    #   playlist.on(:tracks_removed) do |tracks, playlist|
    #     puts "#{tracks.map(&:name).join(', ') removed from #{playlist.name}"
    #   end
    #
    # @yield [tracks, self] tracks_removed
    # @yieldparam [Array<Track>] tracks
    # @yieldparam [Playlist] self
    def tracks_removed_callback(pointer, tracks, num_tracks, userdata)
      trigger(pointer, :tracks_removed, callback_make_tracks(tracks, num_tracks))
    end

    # @example listening to this event
    #   playlist.on(:tracks_moved) do |tracks, new_position, playlist|
    #     puts "#{tracks.map(&:name).join(', ')} moved to #{new_position} to #{playlist.name}"
    #   end
    #
    # @yield [tracks, new_position, self] tracks_moved
    # @yieldparam [Array<Track>] tracks
    # @yieldparam [Integer] new_position
    # @yieldparam [Playlist] self
    def tracks_moved_callback(pointer, tracks, num_tracks, new_position, userdata)
      trigger(pointer, :tracks_moved, callback_make_tracks(tracks, num_tracks), new_position)
    end

    # @example listening to this event
    #   playlist.on(:playlist_renamed) do |playlist|
    #     puts "#{playlist.name} was now previously named something else \o/"
    #   end
    #
    # @yield [self] playlist_renamed
    # @yieldparam [Playlist] self
    def playlist_renamed_callback(pointer, userdata)
      trigger(pointer, :playlist_renamed)
    end

    # @example listening to this event
    #   playlist.on(:playlist_state_changed) do |playlist|
    #     puts "playlist state changed… to what? from what? D:"
    #   end
    #
    # @yield [self] playlist_state_changed
    # @yieldparam [Playlist] self
    def playlist_state_changed_callback(pointer, userdata)
      trigger(pointer, :playlist_state_changed)
    end

    # @example listening to this event
    #   playlist.on(:playlist_update_in_progress) do |is_done, playlist|
    #     puts(is_done ? "DONE!" : "not done :(")
    #   end
    #
    # @yield [is_done, self] playlist_update_in_progress
    # @yieldparam [Boolean] is_done
    # @yieldparam [Playlist] self
    def playlist_update_in_progress_callback(pointer, done, userdata)
      trigger(pointer, :playlist_update_in_progress, done)
    end

    # @example listening to this event
    #   playlist.on(:playlist_metadata_updated) do |playlist|
    #     puts "#{playlist.name} metadata updated"
    #   end
    #
    # @yield [self] playlist_metadata_updated
    # @yieldparam [Playlist] self
    def playlist_metadata_updated_callback(pointer, userdata)
      trigger(pointer, :playlist_metadata_updated)
    end

    # @example listening to this event
    #   playlist.on(:track_created_changed) do |position, user, created_at, playlist|
    #     track = playlist.tracks[position]
    #     puts "#{track.name} created-info changed"
    #   end
    #
    # @yield [position, user, created_at, self] track_created_changed
    # @yieldparam [Integer] position
    # @yieldparam [User] user
    # @yieldparam [Time] created_at
    # @yieldparam [Playlist] self
    def track_created_changed_callback(pointer, position, user, created_at, userdata)
      user = Spotify::Pointer.new(user, :user, true)
      trigger(pointer, :track_created_changed, position, Hallon::User.new(user), Time.at(created_at))
    end

    # @example listening to this event
    #   playlist.on(:track_seen_changed) do |position, seen, playlist|
    #     track = playlist.tracks[position]
    #     puts "#{track.name}#seen? is #{seen}"
    #   end
    #
    # @yield [position, is_seen, self] track_seen_changed
    # @yieldparam [Integer] position
    # @yieldparam [Boolean] is_seen
    # @yieldparam [Playlist] self
    def track_seen_changed_callback(pointer, position, seen, userdata)
      trigger(pointer, :track_seen_changed, position, seen)
    end

    # @example listening to this event
    #   playlist.on(:track_message_changed) do |position, message, playlist|
    #     track = playlist.tracks[position]
    #     puts "#{track.name} new message: #{message}"
    #   end
    #
    # @yield [position, message, self] track_message_changed
    # @yieldparam [Integer] position
    # @yieldparam [String] message
    # @yieldparam [Playlist] self
    def track_message_changed_callback(pointer, position, message, userdata)
      trigger(pointer, :track_message_changed, position, message)
    end

    # @example listening to this event
    #   playlist.on(:description_changed) do |description, playlist|
    #     puts "#{playlist.name} new description: #{description}"
    #   end
    #
    # @yield [description, self] description_changed
    # @yieldparam [String] description
    # @yieldparam [Playlist] self
    def description_changed_callback(pointer, description, userdata)
      trigger(pointer, :description_changed, description)
    end

    # @example listening to this event
    #   playlist.on(:image_changed) do |image, playlist|
    #     puts "#{playlist.name} has got a new image: #{image.to_link}"
    #   end
    #
    # @yield [image, self] image_changed
    # @yieldparam [Image, nil] image or nil
    # @yieldparam [Playlist] self
    def image_changed_callback(pointer, image, userdata)
      image = Hallon::Image.from(image)
      trigger(pointer, :image_changed, image)
    end

    # @example listening to this event
    #   playlist.on(:subscribers_changed) do |playlist|
    #     puts "#{playlist.name} updated its’ subscribers"
    #   end
    #
    # @yield [self] subscribers_changed
    # @yieldparam [Playlist] self
    def subscribers_changed_callback(pointer, userdata)
      trigger(pointer, :subscribers_changed)
    end

    protected
      # @param [FFI::Pointer] tracks
      # @param [Integer] num_tracks
      # @param [Array<Track>]
      def callback_make_tracks(tracks, num_tracks)
        tracks.read_array_of_pointer(num_tracks).map do |track|
          ptr = Spotify::Pointer.new(track, :track, true)
          Hallon::Track.new(ptr)
        end
      end
  end
end
