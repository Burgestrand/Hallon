describe Hallon::Track do
  before :all do
    @track = Hallon::Link.new(TRACK_URI).to_obj
  end
  
  it "can be spawned from a link" do
    @track.class.should equal Hallon::Track
  end
  
  it "can be converted into a link" do
    link = Hallon::Link.new(TRACK_URI)
    track = link.to_obj
    track.to_link.to_str.should == link.to_str
  end
    
  it "should have a name" do
    Hallon::Link.new(TRACK_URI).to_obj.name.should == "Have You Ever"
  end
  
  it "should not be starred" do
    @track.starred?(Hallon::Session.instance).should equal false
  end
  
  it "should be available" do
    @track.available?(Hallon::Session.instance).should equal true
  end
  
  it "should have a duration" do
    if @track.loaded?
      @track.duration.should be > 0
    else
      @track.duration.should == 0
    end
  end
  
  it "should have an error status" do
    @track.error.length.should be > 0
  end
  
  it "should have a popularity" do
    popularity = @track.popularity
    popularity.should be >= 0
    popularity.should be <= 100
  end
end