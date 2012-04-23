# coding: utf-8

RSpec::Core::ExampleGroup.instance_eval do
  let(:mock_artists) do
    {
      default: mock_artist,
      empty:   mock_empty_artist
    }
  end

  let(:mock_artist) do
    Spotify.mock_artist!("Jem", mock_image_id, true)
  end

  let(:mock_artist_two) do
    Spotify.mock_artist!("Maroon 5", mock_image_id, true)
  end

  let(:mock_empty_artist) do
    Spotify.mock_artist!(nil, nil, false)
  end

  let(:mock_artistbrowse) do
    similar_artists    = pointer_array_with(mock_artist, mock_artist_two)
    portraits = pointer_array_with(mock_image_id_pointer, mock_image_id_pointer)
    tracks    = pointer_array_with(mock_track, mock_track_two)
    albums    = pointer_array_with(mock_album)
    tophits   = pointer_array_with(mock_track)

    Spotify.mock_artistbrowse(:ok, 2751, mock_artist, portraits.length, portraits, tracks.length, tracks, albums.length, albums, similar_artists.length, similar_artists, tophits.length, tophits, "grew up in DA BLOCK", :full, nil, nil)
  end

  let(:mock_empty_artistbrowse) do
    Spotify.mock_artistbrowse(:ok, 0, nil, 0, nil, 0, nil, 0, nil, 0, nil, 0, nil, nil, :full, nil, nil)
  end
end
