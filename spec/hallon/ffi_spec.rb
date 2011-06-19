describe FFI::Pointer do
  it "should have a #read_size_t" do
    described_class.instance_methods.should include :read_size_t
  end
end
