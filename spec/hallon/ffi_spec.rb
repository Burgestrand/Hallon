describe FFI::Pointer do
  it "should have a #read_size_t" do
    described_class.method_defined?(:read_size_t).should be_true
  end
end
