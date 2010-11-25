describe Hallon do
  describe "API version" do
    specify { Hallon::API_VERSION.should equal 6 }
  end
  
  describe "URI" do
    subject { Hallon::URI }
    
    [
    'spotify:search:omg%2bwtf%2b%ef%a3%bf%c3%9f%e2%88%82%2bbbq',
    'spotify:track:3oN2Kq1h07LSSBSLYQp0Ns',
    'spotify:album:6I58XCEkOnfUVsfpDehzlQ',
    'spotify:artist:6MF9fzBmfXghAz953czmBC',
    'spotify:user:radiofy.se:playlist:50aHxwoLzq2fvo5g97c2T2',
    'spotify:user:radiofy.se',
    ].each do |uri|
      specify { should match uri }
    end
  end
end