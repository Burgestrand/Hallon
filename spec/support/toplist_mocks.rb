RSpec::Core::ExampleGroup.instance_eval do
  let(:mock_toplists) do
    {
      default: mock_toplistbrowse,
      empty:   mock_empty_toplistbrowse
    }
  end

  let(:mock_toplistbrowse) do
    artists = pointer_array_with(mock_artist, mock_artist_two)
    albums  = pointer_array_with(mock_album)
    tracks  = pointer_array_with(mock_track, mock_track_two)
    Spotify.mock_toplistbrowse(:ok, 2751, artists.length, artists, albums.length, albums, tracks.length, tracks)
  end

  let(:mock_empty_toplistbrowse) do
    Spotify.mock_toplistbrowse(:ok, -1, 0, nil, 0, nil, 0, nil)
  end
end
