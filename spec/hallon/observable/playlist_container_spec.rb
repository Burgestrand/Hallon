describe Hallon::Observable::PlaylistContainer do
  specification_for_callback "playlist_added" do
    let(:input)  { [a_pointer, mock_playlist, 3, :userdata] }
    let(:output) { [Hallon::Playlist.new(mock_playlist), 3] }
  end

  specification_for_callback "playlist_removed" do
    let(:input)  { [a_pointer, mock_playlist, 3, :userdata] }
    let(:output) { [Hallon::Playlist.new(mock_playlist), 3] }
  end

  specification_for_callback "playlist_moved" do
    let(:input)  { [a_pointer, mock_playlist, 3, 8, :userdata] }
    let(:output) { [Hallon::Playlist.new(mock_playlist), 3, 8] }
  end

  specification_for_callback "container_loaded" do
    let(:input)  { [a_pointer, :userdata] }
    let(:output) { [] }
  end
end
