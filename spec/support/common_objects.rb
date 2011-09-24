# coding: utf-8
RSpec::Core::ExampleGroup.instance_eval do
  let(:mock_artist) { Spotify.mock_artist("Jem", true) }
  let(:mock_artist_two) { Spotify.mock_artist("Maroon 5", true) }

  let(:mock_album)  { Spotify.mock_album("Finally Woken", mock_artist, 2004, "DEADBEEFDEADBEEFDEAD", :single, true, true) }
  let(:mock_user)   { Spotify.mock_user("burgestrand", "Burgestrand", "Kim Burgestrand", "https://secure.gravatar.com/avatar/b67b73b5b1fd84119ec788b1c3df02ad", :none, true) }
  let(:mock_image)  { Spotify.mock_image(mock_image_id, :jpeg, File.size(fixture_image_path), File.read(fixture_image_path), :ok) }

  let(:mock_track) do
    artists = pointer_array_with(mock_artist, mock_artist_two)
    Spotify.mock_track("They", artists.length, artists, mock_album, 123_456, 42, 2, 7, 0, true, true, false, true, true)
  end

  let(:mock_track_two) do
    artists = pointer_array_with(mock_artist)
    Spotify.mock_track("Amazing", artists.length, artists, mock_album, 123_456, 42, 2, 7, 0, true, true, false, true, true)
  end

  let(:mock_albumbrowse) do
    copyrights = %w[Kim Elin].map { |x| FFI::MemoryPointer.from_string(x) }
    copyrights = pointer_array_with(*copyrights)
    tracks     = pointer_array_with(mock_track, mock_track_two)
    review     = "This album is AWESOME"
    Spotify.mock_albumbrowse(:ok, mock_album, mock_artist, 2, copyrights, 2, tracks, review, nil, nil)
  end

  let(:mock_artistbrowse) do
    artistbrowse = nil

    mock_image_pointer = FFI::MemoryPointer.from_string(mock_image_id)
    similar_artists    = pointer_array_with(mock_artist, mock_artist_two)
    portraits = pointer_array_with(mock_image_pointer, mock_image_pointer)
    tracks    = pointer_array_with(mock_track, mock_track_two)
    albums    = pointer_array_with(mock_album)

    Spotify.mock_artistbrowse(:ok, mock_artist, portraits.length, portraits, tracks.length, tracks, albums.length, albums, similar_artists.length, similar_artists, "grew up in DA BLOCK", nil, nil)
  end

  let(:mock_toplistbrowse) do
    artists = pointer_array_with(mock_artist, mock_artist_two)
    albums  = pointer_array_with(mock_album)
    tracks  = pointer_array_with(mock_track, mock_track_two)
    Spotify.mock_toplistbrowse(:ok, artists.length, artists, albums.length, albums, tracks.length, tracks)
  end

  let(:mock_image_hex) { "3ad93423add99766e02d563605c6e76ed2b0e450" }
  let(:mock_image_id)  { ":\xD94#\xAD\xD9\x97f\xE0-V6\x05\xC6\xE7n\xD2\xB0\xE4P".force_encoding("BINARY") }
  let(:null_pointer)   { FFI::Pointer.new(0) }

  let(:mock_session_object) do
    session = Hallon::Session.send(:allocate)
    friends = [mock_user] # try moving this into the block and run the tests :d
    session.instance_eval do
      friends = pointer_array_with(*friends)
      @pointer = Spotify.mock_session(nil, friends.length, friends)
    end
    session
  end
end

RSpec::Core::ExampleGroup.new.instance_eval do
  Spotify.registry_add 'spotify:track:7N2Vc8u56VGA4KUrGbikC2', mock_track
  Spotify.registry_add 'spotify:user:burgestrand', mock_user
end
