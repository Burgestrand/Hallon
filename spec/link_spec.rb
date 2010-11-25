describe Hallon::Link do
  it "can parse Spotify URIs" do
    Hallon::Link.new(TRACK_URI).type.should equal :track
  end
  
  it "can render into Spotify URIs" do
    Hallon::Link.new(TRACK_URI).to_str.should == TRACK_URI
  end
  
  it "can be compared with other Spotify URIs" do
    @link = Hallon::Link.new(TRACK_URI)
    TRACK_URI.should == @link
    @link.should == Hallon::Link.new(TRACK_URI)
  end
  
  it "should have the the same ID as the Spotify URL" do
    Hallon::Link.new(TRACK_URI).id.should == TRACK_URI.match('spotify:track:([\w\d]+)')[1]
  end
end