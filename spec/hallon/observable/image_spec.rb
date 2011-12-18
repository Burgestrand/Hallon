describe Hallon::Observable::Image do
  specification_for_callback "load" do
    let(:type)   { :image_loaded_cb }
    let(:input)  { [a_pointer, :userdata] }
    let(:output) { [subject] }
  end
end

