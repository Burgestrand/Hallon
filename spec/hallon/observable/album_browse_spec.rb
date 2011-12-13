describe Hallon::Observable::AlbumBrowse do
  it { should include Hallon::Observable }

  specification_for_callback "load" do
    let(:type)   { :albumbrowse_complete_cb }
    let(:input)  { [a_pointer, :userdata] }
    let(:output) { [subject] }
  end
end
