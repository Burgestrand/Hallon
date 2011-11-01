describe Hallon do
  describe "VERSION" do
    specify { Hallon::VERSION.should be_a String }
  end

  describe "API_VERSION" do
    specify { Hallon::API_VERSION.should == 10 }
  end

  describe "API_BUILD" do
    specify { Hallon::API_BUILD.should be_a String }
  end

  describe "URI" do
    subject { Hallon::URI }
    example_uris.keys.each do |uri|
      it { should match uri }
    end
  end
end
