describe Hallon do
  describe "Version" do
    specify { Hallon::Version::STRING.should == "0.0.0" }
  end
  
  describe "API_VERSION" do
    specify { Hallon::API_VERSION.should == 7 }
  end
  
  describe "URI" do
    subject { Hallon::URI }
    example_uris.keys.each do |uri|
      it { should match uri }
    end
  end
end