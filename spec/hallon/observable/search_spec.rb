describe Hallon::Observable::Search do
  it { should include Hallon::Observable }

  specification_for_callback "load" do
    let(:type)   { :search_complete_cb }
    let(:input)  { [a_pointer, :userdata] }
    let(:output) { [subject] }
  end
end
