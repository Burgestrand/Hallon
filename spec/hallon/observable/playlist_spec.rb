describe Hallon::Observable::Playlist do
  let(:trackpointers_size) { 2 }
  let(:track_index_pointers) do
    tracks = FFI::MemoryPointer.new(:pointer, trackpointers_size)
    tracks.write_array_of_int([0, 1])
    tracks
  end

  let(:trackpointers) do
    tracks = FFI::MemoryPointer.new(:pointer, trackpointers_size)
    tracks.write_array_of_pointer([mock_track, mock_track_two])
    tracks
  end

  let(:tracks) do
    instantiate(Hallon::Track, mock_track, mock_track_two)
  end

  specification_for_callback "tracks_added" do
    let(:input)  { [a_pointer, trackpointers, trackpointers_size, 0, :userdata] }
    let(:output) { [tracks, 0] }
  end

  specification_for_callback "tracks_removed" do
    let(:input)  { [a_pointer, track_index_pointers, trackpointers_size, :userdata] }
    let(:output) { [[0, 1]] }
  end

  specification_for_callback "tracks_moved" do
    let(:input)  { [a_pointer, track_index_pointers, trackpointers_size, 7, :userdata] }
    let(:output) { [[0, 1], 7] }
  end

  specification_for_callback "playlist_renamed" do
    let(:input)  { [a_pointer, :userdata] }
    let(:output) { [] }
  end

  specification_for_callback "playlist_state_changed" do
    let(:input)  { [a_pointer, :userdata] }
    let(:output) { [] }
  end

  specification_for_callback "playlist_update_in_progress" do
    let(:input)  { [a_pointer, true, :userdata] }
    let(:output) { [true] }
  end

  specification_for_callback "playlist_metadata_updated" do
    let(:input)  { [a_pointer, :userdata] }
    let(:output) { [] }
  end

  specification_for_callback "track_created_changed" do
    let(:input)  { [a_pointer, 7, mock_user, 15, :userdata] }
    let(:output) { [7, Hallon::User.new(mock_user), Time.at(15)] }
  end

  specification_for_callback "track_seen_changed" do
    let(:input)  { [a_pointer, 0, true, :userdata] }
    let(:output) { [0, true] }
  end

  specification_for_callback "track_message_changed" do
    let(:input)  { [a_pointer, 13, "I LUFF JOO!", :userdata] }
    let(:output) { [13, "I LUFF JOO!"] }
  end

  specification_for_callback "description_changed" do
    let(:input)  { [a_pointer, "Merily merily merily bong", :userdata] }
    let(:output) { ["Merily merily merily bong"] }
  end

  specification_for_callback "image_changed" do
    before { Hallon::Session.stub!(:instance => session) }
    let(:input)  { [a_pointer, mock_image_id, :userdata] }
    let(:output) { [Hallon::Image.new(mock_image)] }

    it "should not fail if the image has been *removed*" do
      block = proc { |image| }
      block.should_receive(:call).with(nil)
      subject.on(:image_changed, &block)
      subject_callback.call(a_pointer, null_pointer, :userdata)
    end
  end

  specification_for_callback "subscribers_changed" do
    let(:input)  { [a_pointer, :userdata] }
    let(:output) { [] }
  end
end
