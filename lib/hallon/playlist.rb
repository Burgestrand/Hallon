# coding: utf-8
module Hallon
  # Playlists are playlists. They contain tracks and track information
  # such as when tracks were added or by whom. They also contain some
  # metadata such as their own name.
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__playlist.html
  class Playlist < Base
    include Observable
    extend Linkable

    # Playlist::Track is a {Track} with additional information attached to it,
    # that is specific to the playlist it was created from. The returned track
    # is a snapshot of the information, so even if the underlying track moves,
    # this Playlist::Track will still contain the same information.
    #
    # There is no way to refresh the information. You’ll have to retrieve the
    # track again.
    class Track < Hallon::Track
      def initialize(pointer, playlist, index)
        super(pointer)

        @index       = index
        @playlist    = playlist
        @create_time = Time.at Spotify.playlist_track_create_time(playlist.pointer, index)
        @message     = Spotify.playlist_track_message(playlist.pointer, index)
        @seen        = Spotify.playlist_track_seen(playlist.pointer, index)
        @creator     = begin
          creator = Spotify.playlist_track_creator!(playlist.pointer, index)
          User.new(creator) unless creator.null?
        end
      end

      # @note this value never changes, even if the original track is moved/removed
      # @return [Integer] index this track was created with.
      attr_reader :index

      # @return [Playlist] playlist this track was created from.
      attr_reader :playlist

      # @return [Time] time when track at {#index} was added to playlist.
      attr_reader :create_time

      # @return [User, nil] person who added track at {#index} to this playlist.
      attr_reader :creator

      # @return [String] message attached to this track at {#index}.
      attr_reader :message

      # @see Playlist#seen
      # @return [Boolean] true if track at {#index} has been seen.
      def seen?
        @seen
      end

      # Set seen status of the Playlist::Track at the given index.
      #
      # @note Word of warning; this method will update the value you get from {#seen?}!
      # @raise [IndexError] if the underlying track has moved
      # @raise [Error] if the operation could not be completed
      #
      # @param [Integer] index
      # @param [Boolean] seen true if the track is now seen
      # @return [Playlist::Track] track at the given index
      def seen=(seen)
        if moved?
          raise IndexError, "track has moved from #{index}"
        end

        error = Spotify.playlist_track_set_seen(playlist.pointer, index, !! seen)
        Error.maybe_raise(error)
        @seen = Spotify.playlist_track_seen(playlist.pointer, index)
      end

      # @return [Boolean] true if the track has not yet moved.
      def moved?
        # using non-GC version deliberately; no need to keep a reference to
        # this pointer once we’re done here anyway
        Spotify.playlist_track(playlist.pointer, index) != pointer
      end
    end

    from_link :playlist do |pointer|
      Spotify.playlist_create!(session.pointer, pointer)
    end

    to_link :from_playlist

    # Construct a new Playlist, given a pointer.
    #
    # @param [String, Link, FFI::Pointer] link
    def initialize(link)
      @pointer = to_pointer(link, :playlist)

      callbacks = Spotify::PlaylistCallbacks.create(self, @sp_callbacks = {})
      Spotify.playlist_add_callbacks(pointer, callbacks, nil)
    end

    # @return [Boolean] true if the playlist is loaded
    def loaded?
      Spotify.playlist_is_loaded(pointer)
    end

    # @return [Boolean] true if the playlist is collaborative
    def collaborative?
      Spotify.playlist_is_collaborative(pointer)
    end

    # @param [Boolean] collaborative true to set the playlist to collaborative
    def collaborative=(collaborative)
      Spotify.playlist_set_collaborative(pointer, !!collaborative)
    end

    # @return [Boolean] true if playlist has pending changes
    def pending?
      Spotify.playlist_has_pending_changes(pointer)
    end

    # @return [Boolean] true if the playlist is in RAM
    def in_ram?
      Spotify.playlist_is_in_ram(session.pointer, pointer)
    end

    # @param [Boolean] in_ram true if you want to store the playlist in RAM
    def in_ram=(in_ram)
      Spotify.playlist_set_in_ram(session.pointer, pointer, !! in_ram)
    end

    # @return [Boolean] true if playlist is available offline (fully synced)
    def available_offline?
      offline_status == :yes
    end

    # @return [Boolean] true if playlist is currently syncing
    def syncing?
      offline_status == :downloading
    end

    # @return [Boolean] true if playlist is queued for offline syncing
    def waiting?
      offline_status == :waiting
    end

    # @return [Boolean] true if playlist is requested to be available offline
    def offline_mode?
      offline_status != :no
    end

    # @return [Symbol] one of :no, :yes, :downloading, :waiting
    def offline_status
      Spotify.playlist_get_offline_status(session.pointer, pointer)
    end

    # @param [Boolean] available_offline true if you want this playlist available offline
    def offline_mode=(available_offline)
      Spotify.playlist_set_offline_mode(session.pointer, pointer, !! available_offline)
    end

    # @return [String]
    def name
      Spotify.playlist_name(pointer)
    end

    # @note The name must not consist of only spaces and it must be shorter than 256 characters.
    # @param [#to_s] name new name for playlist
    # @raise [Error] if name could not be changed
    def name=(name)
      name = name.to_s.encode('UTF-8')

      unless name.length < 256
        raise ArgumentError, "name must be shorter than 256 characters (UTF-8)"
      end

      unless name =~ /[^ ]/u
        raise ArgumentError, "name must not consist of only spaces"
      end unless name.empty?

      Error.maybe_raise(Spotify.playlist_rename(pointer, name))
    end

    # @return [User, nil]
    def owner
      user = Spotify.playlist_owner!(pointer)
      User.new(user) unless user.null?
    end

    # @return [String]
    def description
      Spotify.playlist_get_description(pointer)
    end

    # @return [Image, nil]
    def image
      buffer = FFI::Buffer.alloc_out(20)
      if Spotify.playlist_get_image(pointer, buffer)
        Image.new buffer.read_bytes(20)
      end
    end

    # @note this list might be shorter than {#total_subscribers}, as
    #       libspotify does not store more than 500 subscriber names
    # @return [Array<String>] list of canonical usernames
    def subscribers
      ptr = Spotify.playlist_subscribers(pointer)

      begin
        struct = Spotify::Subscribers.new(ptr)

        if struct[:count].zero?
          []
        else
          struct[:subscribers].map(&:read_string)
        end
      ensure
        Spotify.playlist_subscribers_free(ptr)
      end unless ptr.null?
    end

    # @return [Integer] total number of subscribers.
    def total_subscribers
      Spotify.playlist_num_subscribers(pointer)
    end

    # Ask libspotify to update subscriber information
    #
    # @return [Playlist]
    def update_subscribers
      Spotify.playlist_update_subscribers(session.pointer, pointer)
    end

    # @note only applicable if {#offline_status} is `:downloading`
    # @return [Integer] percentage done of playlist offline sync
    def sync_progress
      Spotify.playlist_get_offline_download_completed(session.pointer, pointer)
    end

    # @param [Boolean] autolink_tracks if you want unplayable tracks to be linked to playable tracks (if possible)
    def autolink_tracks=(autolink_tracks)
      Spotify.playlist_set_autolink_tracks(pointer, !! autolink_tracks)
    end

    # @note Will be 0 unless {#loaded?}.
    # @return [Integer] number of tracks in playlist
    def size
      Spotify.playlist_num_tracks(pointer)
    end

    # @example retrieve track at index 3
    #   track = playlist.tracks[3]
    #   puts track.name
    #
    # @return [Enumerable<Playlist::Track>] a list of playlist tracks.
    def tracks
      Enumerator.new(size) do |index|
        track = Spotify.playlist_track!(pointer, index)
        Playlist::Track.new(track, self, index) unless track.null?
      end
    end

    # Add a list of tracks to the playlist starting at given position.
    #
    # @param [Integer] index starting index to add tracks from (between 0..{#size})
    # @param [Track, Array<Track>] tracks
    # @return [Playlist]
    # @raise [Hallon::Error] if the operation failed
    def insert(index = size, tracks)
      tracks = Array(tracks).map(&:pointer)
      tracks_ary = FFI::MemoryPointer.new(:pointer, tracks.size)
      tracks_ary.write_array_of_pointer(tracks)

      tap do
        error = Spotify.playlist_add_tracks(pointer, tracks_ary, tracks.size, index, session.pointer)
        Error.maybe_raise(error)
      end
    end

    # Remove tracks at given indices.
    #
    # @param [Integer, ...] indices
    # @return [Playlist]
    # @raise [Error] if the operation failed
    def remove(*indices)
      indices_ary = FFI::MemoryPointer.new(:int, indices.size)
      indices_ary.write_array_of_int(indices)

      tap do
        error = Spotify.playlist_remove_tracks(pointer, indices_ary, indices.size)
        Error.maybe_raise(error)
      end
    end

    # Move tracks at given indices to given index.
    #
    # @param [Integer] destination index to move tracks to
    # @param [Integer, Array<Integer>] indices
    # @return [Playlist]
    # @raise [Error] if the operation failed
    def move(destination, indices)
      indices     = Array(indices)
      indices_ary = FFI::MemoryPointer.new(:int, indices.size)
      indices_ary.write_array_of_int(indices)

      tap do
        error = Spotify.playlist_reorder_tracks(pointer, indices_ary, indices.size, destination)
        Error.maybe_raise(error)
      end
    end
  end
end
