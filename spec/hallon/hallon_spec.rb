describe Hallon do
  describe "VERSION" do
    specify { Hallon::Version::STRING.should == "0.0.0" }
  end
  
  describe "API_VERSION" do
    specify { Hallon::API_VERSION.should == 6 }
  end
  
  describe "URI" do
    subject { Hallon::URI }
    
    %w(spotify:search:omg%2bwtf%2b%ef%a3%bf%c3%9f%e2%88%82%2bbbq
       spotify:track:3oN2Kq1h07LSSBSLYQp0Ns
       spotify:album:6I58XCEkOnfUVsfpDehzlQ
       spotify:artist:6MF9fzBmfXghAz953czmBC
       spotify:user:burgestrand:playlist:4nQnbGi4kALbME9csEqdW2
       spotify:user:burgestrand).each do |uri|
      specify { should match uri }
    end
  end
end