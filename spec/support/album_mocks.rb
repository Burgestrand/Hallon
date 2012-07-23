# coding: utf-8

RSpec::Core::ExampleGroup.instance_eval do
  let(:mock_albums) do
    {
      default: mock_album,
      empty:   mock_empty_album
    }
  end

  let(:mock_album) do
    Spotify.mock_album_create("Finally Woken", mock_artist, 2004, mock_image_id, :single, true, true)
  end

  let(:mock_empty_album) do
    Spotify.mock_album_create(nil, nil, 0, nil, :single, false, false)
  end

  let(:mock_albumbrowse) do
    copyrights = %w[Kim Elin].map { |x| FFI::MemoryPointer.from_string(x) }
    copyrights = pointer_array_with(*copyrights)
    tracks     = pointer_array_with(mock_track, mock_track_two)
    review     = "This album is AWESOME"
    Spotify.mock_albumbrowse_create(:ok, 2751, mock_album, mock_artist, 2, copyrights, 2, tracks, review, nil, nil)
  end

  let(:mock_empty_albumbrowse) do
    Spotify.mock_albumbrowse_create(:ok, -1, nil, nil, 0, nil, 0, nil, nil, nil, nil)
  end
end
