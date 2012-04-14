describe Hallon::Observable::Post do
  specification_for_callback "complete" do
    let(:type)   { :inboxpost_complete_cb }
    let(:input)  { [a_pointer, :userdata] }
    let(:output) { [] }
  end
end

