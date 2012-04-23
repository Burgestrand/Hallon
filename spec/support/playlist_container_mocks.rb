RSpec::Core::ExampleGroup.instance_eval do
  let(:mock_containers) do
    {
      default: mock_container,
      empty:   mock_empty_container
    }
  end

  let(:mock_container) do
    num_items = 4
    items_ptr = FFI::MemoryPointer.new(Spotify::Mock::PlaylistContainerItem, num_items)
    items = num_items.times.map do |i|
      Spotify::Mock::PlaylistContainerItem.new(items_ptr + Spotify::Mock::PlaylistContainerItem.size * i)
    end

    items[0][:playlist] = mock_playlist
    items[0][:type]     = :playlist

    items[1][:folder_name] = FFI::MemoryPointer.from_string("Boogie")
    items[1][:type]        = :start_folder
    items[1][:folder_id]   = 1337

    items[2][:playlist] = mock_playlist_two
    items[2][:type]     = :playlist

    items[3][:folder_name] = FFI::Pointer::NULL
    items[3][:type]        = :end_folder
    items[3][:folder_id]   = 1337

    Spotify.mock_playlistcontainer!(mock_user, true, num_items, items_ptr, nil, nil)
  end

  let(:mock_empty_container) do
    Spotify.mock_playlistcontainer!(nil, false, 0, nil, nil, nil)
  end
end
