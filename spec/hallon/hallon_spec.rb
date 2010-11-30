describe Hallon do
  describe "VERSION" do
    specify { Hallon::VERSION.should == "0.0.0" }
  end
  
  describe "API_VERSION" do
    specify { Hallon::API_VERSION.should == 6 }
  end
end