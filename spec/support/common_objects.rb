# coding: utf-8
RSpec::Core::ExampleGroup.instance_eval do
  let(:mock_artist) { Spotify.mock_artist("Jem", true) }
  let(:mock_artist_two) { Spotify.mock_artist("Maroon 5", true) }

  let(:mock_album)  { Spotify.mock_album("Finally Woken", mock_artist, 2004, "DEADBEEFDEADBEEFDEAD", :single, true, true) }
  let(:mock_user)   { Spotify.mock_user("burgestrand", "Burgestrand", "Kim Burgestrand", "https://secure.gravatar.com/avatar/b67b73b5b1fd84119ec788b1c3df02ad", :none, true) }
  let(:mock_image)  { Spotify.mock_image(mock_image_id, :jpeg, File.size(fixture_image_path), File.read(fixture_image_path), :ok) }

  let(:mock_track) do
    track = nil
    FFI::MemoryPointer.new(:pointer, 2) do |ary|
      ary.write_array_of_pointer [mock_artist, mock_artist_two]
      track = Spotify.mock_track("They", ary.size / ary.type_size, ary, mock_album, 123_456, 42, 2, 7, 0, true, true, false, true, true)
    end
    track
  end

  let(:mock_track_two) do
    track = nil
    FFI::MemoryPointer.new(:pointer, 1) do |ary|
      ary.write_array_of_pointer [mock_artist]
      track = Spotify.mock_track("Amazing", ary.size / ary.type_size, ary, mock_album, 123_456, 42, 2, 7, 0, true, true, false, true, true)
    end
    track
  end

  let(:mock_albumbrowse) do
    albumbrowse = nil

    FFI::MemoryPointer.new(:pointer, 2) do |copyrights|
      FFI::MemoryPointer.new(:pointer, 2) do |tracks|
        copyrights.write_array_of_pointer %w[Kim Elin].map { |x| FFI::MemoryPointer.from_string(x) }
        tracks.write_array_of_pointer [mock_track, mock_track_two]
        review = "This album is AWESOME"
        albumbrowse = Spotify.mock_albumbrowse(:ok, mock_album, mock_artist, 2, copyrights, 2, tracks, review, nil, nil)
      end
    end

    albumbrowse
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

  let(:mock_image_hex) { "3ad93423add99766e02d563605c6e76ed2b0e450" }
  let(:mock_image_id)  { ":\xD94#\xAD\xD9\x97f\xE0-V6\x05\xC6\xE7n\xD2\xB0\xE4P".force_encoding("BINARY") }
  let(:null_pointer)   { FFI::Pointer.new(0) }
end

RSpec::Core::ExampleGroup.new.instance_eval do
  Spotify.registry_add 'spotify:track:7N2Vc8u56VGA4KUrGbikC2', mock_track
  Spotify.registry_add 'spotify:user:burgestrand', mock_user
end
