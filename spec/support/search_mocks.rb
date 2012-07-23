# coding: utf-8

RSpec::Core::ExampleGroup.instance_eval do
  let(:mock_searches) do
    {
      default: mock_search,
      empty:   mock_empty_search
    }
  end

  let(:mock_search) do
    artists   = pointer_array_with(mock_artist, mock_artist_two)
    albums    = pointer_array_with(mock_album)
    tracks    = pointer_array_with(mock_track, mock_track_two)
    playlists = pointer_array_with(mock_playlist_two)

    Spotify.mock_search_create(:ok, "my å utf8  query", "another thing", 1337, tracks.length, tracks, 42, albums.length, albums, 81104, artists.length, artists, 0716, playlists.length, playlists, nil, nil)
  end

  let(:mock_empty_search) do
    Spotify.mock_search_create(:ok, "", nil, 0, 0, nil, 0, 0, nil, 0, 0, nil, 0, 0, nil, nil, nil)
  end
end
