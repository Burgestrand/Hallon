# coding: utf-8
require 'time'

RSpec::Core::ExampleGroup.instance_eval do
  let(:mock_user)   { Spotify.mock_user!("burgestrand", "Burgestrand", true) }
  let(:mock_user_raw) { FFI::Pointer.new(mock_user.address) }

  let(:mock_track) do
    artists = pointer_array_with(mock_artist, mock_artist_two)
    Spotify.mock_track!("They", artists.length, artists, mock_album, 123_456, 42, 2, 7, :ok, true, :available, :done, false, true, nil, true, false)
  end

  let(:mock_track_two) do
    artists = pointer_array_with(mock_artist)
    Spotify.mock_track!("Amazing", artists.length, artists, mock_album, 123_456, 42, 2, 7, :ok, true, :available, :no, false, true, nil, true, true)
  end

  let(:mock_linked_track) do
    artists = pointer_array_with(mock_artist_two)
    Spotify.mock_track!("They", artists.length, artists, mock_album, 60, 100, 1, 1, :ok, true, :available, :no, false, true, mock_track, false, false)
  end

  let(:mock_toplistbrowse) do
    artists = pointer_array_with(mock_artist, mock_artist_two)
    albums  = pointer_array_with(mock_album)
    tracks  = pointer_array_with(mock_track, mock_track_two)
    Spotify.mock_toplistbrowse(:ok, 2751, artists.length, artists, albums.length, albums, tracks.length, tracks)
  end

  let(:mock_search) do
    artists   = pointer_array_with(mock_artist, mock_artist_two)
    albums    = pointer_array_with(mock_album)
    tracks    = pointer_array_with(mock_track, mock_track_two)
    playlists = pointer_array_with(mock_playlist, mock_playlist_two)

    Spotify.mock_search(:ok, "my å utf8  query", "another thing", 1337, tracks.length, tracks, 42, albums.length, albums, 81104, artists.length, artists, 0716, playlists.length, playlists, nil, nil)
  end

  let(:mock_subscribers) do
    people = %w[Kim Elin Ylva]
    people.map! { |x| FFI::MemoryPointer.from_string(x) }

    subscribers = FFI::MemoryPointer.new(:pointer, people.size)
    subscribers.write_array_of_pointer people

    Spotify.mock_subscribers(people.count, subscribers)
  end

  let(:mock_empty_subscribers) do
    Spotify.mock_subscribers(0, nil)
  end

  let(:null_pointer)   { FFI::Pointer.new(0) }
  let(:a_pointer)      { FFI::Pointer.new(1) }

  let(:mock_offline_sync_status) do
    sync = Spotify::OfflineSyncStatus.new
    mock_offline_sync_status_hash.each_pair do |key, value|
      sync[key] = value
    end
    sync
  end

  let(:mock_offline_sync_status_hash) do
    {
      :queued_tracks => 1,
      :queued_bytes  => 2,
      :done_tracks   => 3,
      :done_bytes    => 4,
      :copied_tracks => 5,
      :copied_bytes  => 6,
      :error_tracks  => 8,
      :syncing       => false,
      :willnotcopy_tracks => 7
    }
  end

  let(:mock_session_object) do
    session = Hallon::Session.send(:allocate)
    sstatus = mock_offline_sync_status
    inbox   = mock_playlist
    session.instance_eval do
      @pointer = Spotify.mock_session(nil, :undefined, 60 * 60 * 24 * 30, sstatus, 7, 3, inbox)
    end
    session
  end
end

RSpec.configure do |config|
  config.before do
    Spotify.registry_add 'spotify:track:7N2Vc8u56VGA4KUrGbikC2', mock_track
    Spotify.registry_add 'spotify:user:burgestrand', mock_user
    Spotify.registry_add 'spotify:user:burgestrand:playlist:07AX9IY9Hqmj1RqltcG0fi', mock_playlist
    Spotify.registry_add 'spotify:user:burgestrand:starred', mock_playlist
    Spotify.registry_add 'spotify:search:my+%C3%A5+utf8+%EF%A3%BF+query', mock_search
  end

  config.after do
    Spotify.registry_clean
  end
end
