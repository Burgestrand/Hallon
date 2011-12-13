describe Hallon::Observable::Post do
  it { should include Hallon::Observable }

  specification_for_callback "complete" do
    let(:type)   { :inboxpost_complete_cb }
    let(:input)  { [a_pointer, :userdata] }
    let(:output) { [subject] }
  end
end

