describe Hallon::Observable::Playlist do
  it { should include Hallon::Observable }

  let(:trackpointers_size) { 2 }
  let(:trackpointers) do
    tracks = FFI::MemoryPointer.new(:pointer, 2)
    tracks.write_array_of_pointer([mock_track, mock_track_two])
    tracks
  end

  let(:tracks) do
    instantiate(Hallon::Track, mock_track, mock_track_two)
  end

  specification_for_callback "tracks_added" do
    let(:input)  { [a_pointer, trackpointers, trackpointers_size, 0, :userdata] }
    let(:output) { [tracks, 0, subject] }
  end

  specification_for_callback "tracks_removed" do
    let(:input)  { [a_pointer, trackpointers, trackpointers_size, :userdata] }
    let(:output) { [tracks, subject] }
  end

  specification_for_callback "tracks_moved" do
    let(:input)  { [a_pointer, trackpointers, trackpointers_size, 7, :userdata] }
    let(:output) { [tracks, 7, subject] }
  end

  specification_for_callback "playlist_renamed" do
    let(:input)  { [a_pointer, :userdata] }
    let(:output) { [subject] }
  end

  specification_for_callback "playlist_state_changed" do
    let(:input)  { [a_pointer, :userdata] }
    let(:output) { [subject] }
  end

  specification_for_callback "playlist_update_in_progress" do
    let(:input)  { [a_pointer, true, :userdata] }
    let(:output) { [true, subject] }
  end

  specification_for_callback "playlist_metadata_updated" do
    let(:input)  { [a_pointer, :userdata] }
    let(:output) { [subject] }
  end

  specification_for_callback "track_created_changed" do
    let(:input)  { [a_pointer, 7, mock_user_raw, 15, :userdata] }
    let(:output) { [7, Hallon::User.new(mock_user), Time.at(15), subject] }
  end

  specification_for_callback "track_seen_changed" do
    let(:input)  { [a_pointer, 0, true, :userdata] }
    let(:output) { [0, true, subject] }
  end

  specification_for_callback "track_message_changed" do
    let(:input)  { [a_pointer, 13, "I LUFF JOO!", :userdata] }
    let(:output) { [13, "I LUFF JOO!", subject] }
  end

  specification_for_callback "description_changed" do
    let(:input)  { [a_pointer, "Merily merily merily bong", :userdata] }
    let(:output) { ["Merily merily merily bong", subject] }
  end

  specification_for_callback "image_changed" do
    let(:input)  { [a_pointer, mock_image_id_pointer, :userdata] }
    let(:output) { mock_session { [Hallon::Image.new(mock_image), subject] } }
  end

  specification_for_callback "subscribers_changed" do
    let(:input)  { [a_pointer, :userdata] }
    let(:output) { [subject] }
  end
end
