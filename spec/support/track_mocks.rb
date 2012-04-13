RSpec::Core::ExampleGroup.instance_eval do
  let(:mock_tracks) do
    {
      default: mock_track,
      empty:   mock_empty_track
    }
  end

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

  let(:mock_empty_track) do
    Spotify.mock_track!(nil, 0, nil, nil, 0, 0, 0, 0, :ok, false, :unavailable, :no, false, true, nil, false, false)
  end
end
