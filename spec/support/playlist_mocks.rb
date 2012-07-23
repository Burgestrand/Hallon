# coding: utf-8

RSpec::Core::ExampleGroup.instance_eval do
  let(:mock_playlists) do
    {
      default: mock_playlist,
      empty:   mock_empty_playlist
    }
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

  let(:mock_playlist) do
    num_tracks = 4
    tracks_ptr = FFI::MemoryPointer.new(Spotify::Mock::PlaylistTrack, num_tracks)
    tracks = num_tracks.times.map do |i|
      Spotify::Mock::PlaylistTrack.new(tracks_ptr + Spotify::Mock::PlaylistTrack.size * i)
    end

    tracks[0][:track] = mock_track
    tracks[0][:create_time] = Time.parse("2009-11-04").to_i
    tracks[0][:creator] = mock_user
    tracks[0][:message] = FFI::MemoryPointer.from_string("message this, YO!")
    tracks[0][:seen] = true

    tracks[1][:track] = mock_track_two
    tracks[1][:create_time] = Time.parse("2009-11-05").to_i
    tracks[1][:creator] = mock_user
    tracks[1][:message] = FFI::MemoryPointer.from_string("message this, YO!")
    tracks[1][:seen] = true

    tracks[2][:track] = mock_track
    tracks[2][:create_time] = Time.parse("2009-11-06").to_i
    tracks[2][:creator] = mock_user
    tracks[2][:message] = FFI::MemoryPointer.from_string("message this, YO!")
    tracks[2][:seen] = true

    tracks[3][:track] = mock_track_two
    tracks[3][:create_time] = 0
    tracks[3][:creator] = nil
    tracks[3][:message] = nil
    tracks[3][:seen] = true

    Spotify.mock_playlist_create("Megaplaylist", true, mock_user, true, "Playlist description...?", mock_image_id, false, 1000, mock_subscribers, true, :no, 67, num_tracks, tracks_ptr)
  end

  let(:mock_playlist_two) do
    Spotify.mock_playlist_create("Dunderlist", true, mock_user, true, nil, mock_image_id, false, 1000, nil, true, :no, 0, 0, nil)
  end

  let(:mock_empty_playlist) do
    Spotify.mock_playlist_create(nil, false, nil, false, nil, nil, false, 0, nil, false, :no, 0, 0, nil)
  end

  let(:mock_playlist_raw) do
    FFI::Pointer.new(mock_playlist.address)
  end
end
