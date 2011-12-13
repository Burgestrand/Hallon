describe Hallon::Observable::Toplist do
  it { should include Hallon::Observable }

  specification_for_callback "load" do
    let(:type)   { :toplistbrowse_complete_cb }
    let(:input)  { [a_pointer, :userdata] }
    let(:output) { [subject] }
  end
end


