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

    # Oh, ain’t this beautiful…?
    FFI::MemoryPointer.new(:pointer, 2) do |portraits|
      FFI::MemoryPointer.new(:pointer, 2) do |tracks|
        FFI::MemoryPointer.new(:pointer, 2) do |albums|
          FFI::MemoryPointer.new(:pointer, 2) do |similar_artists|
            mock_image_pointer = FFI::MemoryPointer.from_string(mock_image_id)
            portraits.write_array_of_pointer [mock_image_pointer, mock_image_pointer]
            tracks.write_array_of_pointer [mock_track, mock_track_two]
            albums.write_array_of_pointer [mock_album] # laziness
            similar_artists.write_array_of_pointer [mock_artist, mock_artist_two]

            artistbrowse = Spotify.mock_artistbrowse(:ok, mock_artist, 2, portraits, 2, tracks, 1, albums, 2, similar_artists, "grew up in DA BLOCK", nil, nil)
          end
        end
      end
    end

    artistbrowse
  end

  let(:mock_toplistbrowse) do
    toplistbrowse = nil

    FFI::MemoryPointer.new(:pointer, 2) do |artists|
      FFI::MemoryPointer.new(:pointer, 1) do |albums|
        FFI::MemoryPointer.new(:pointer, 2) do |tracks|
            artists.write_array_of_pointer [mock_artist, mock_artist_two]
            albums.write_array_of_pointer [mock_album] # laziness
            tracks.write_array_of_pointer [mock_track, mock_track_two]

            toplistbrowse = Spotify.mock_toplistbrowse(:ok, 2, artists, 1, albums, 2, tracks)
        end
      end
    end

    toplistbrowse
  end

  let(:mock_image_hex) { "3ad93423add99766e02d563605c6e76ed2b0e450" }
  let(:mock_image_id)  { ":\xD94#\xAD\xD9\x97f\xE0-V6\x05\xC6\xE7n\xD2\xB0\xE4P".force_encoding("BINARY") }
  let(:null_pointer)   { FFI::Pointer.new(0) }

  let(:mock_session_object) do
    session = Hallon::Session.send(:allocate)
    FFI::MemoryPointer.new(:pointer) do |friends|
      friends.write_array_of_pointer [mock_user]
      session.instance_eval do
        @pointer = Spotify.mock_session(nil, 1, friends)
      end
    end
    session
  end
end

RSpec::Core::ExampleGroup.new.instance_eval do
  Spotify.registry_add 'spotify:track:7N2Vc8u56VGA4KUrGbikC2', mock_track
  Spotify.registry_add 'spotify:user:burgestrand', mock_user
end
