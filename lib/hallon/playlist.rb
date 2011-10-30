module Hallon
  # Playlists are playlists. They contain tracks and track information
  # such as when tracks were added or by whom. They also contain some
  # metadata such as their own name.
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__playlist.html
  class Playlist < Base
    include Observable
    extend Linkable

    # Playlist::Track is an object that is similar to tracks in many
    # ways, but it also has a reference to the playlist that created
    # it and the index it is placed on.
    class Track < Track
      attr_reader :index
      attr_reader :playlist

      def initialize(playlist, index)
        super(Spotify.playlist_track!(playlist, index))

        @playlist = playlist
        @index    = index
      end

      # @return [Time] time when track at {#index} was added to playlist
      def create_time
        Time.at Spotify.playlist_track_create_time(playlist, index)
      end

      # @return [User, nil] person who added track at {#index} to this playlist
      def creator
        creator = Spotify.playlist_track_creator!(playlist, index)
        User.new(creator) unless creator.null?
      end

      # @return [String] message attached to this track at {#index}
      def message
        Spotify.playlist_track_message(playlist, index)
      end

      # @return [Boolean] true if track at {#index} has been seen
      def seen?
        Spotify.playlist_track_seen(playlist, index)
      end

      # @raise [Error] if index is out of range
      # @param [Boolean] set seen status of track at {#index}
      def seen=(seen)
        error = Spotify.playlist_track_set_seen(playlist, index, !! seen)
        Error.maybe_raise(error)
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
      callbacks = Spotify::PlaylistCallbacks.new(self, @sp_callbacks = {})
      @pointer = to_pointer(link, :playlist)
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
      end

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
      ptr    = Spotify.playlist_subscribers(pointer)
      struct = Spotify::Subscribers.new(ptr)

      struct[:subscribers].map(&:read_string)
    ensure
      Spotify.playlist_subscribers_free(ptr)
    end

    # @return [Integer] total number of subscribers
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

    # @return [Enumerable<Playlist::Track>] a list of playlist tracks
    def tracks
      Enumerator.new(size) do |i|
        Playlist::Track.new(pointer, i)
      end
    end
  end
end
