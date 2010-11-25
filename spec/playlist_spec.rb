describe Hallon::Playlist do
  before :all do
    @session = Hallon::Session.instance.login(USERNAME, PASSWORD)
    @session.logged_in?.should equal true
    @playlist = @session.playlists.push PLAYLIST
  end
  
  after :all do
    @session.playlists.delete @playlist
    @session.logout
  end
  
  it "can be spawned from a link" do
    Hallon::Link.new(PLAYLIST_URI).to_obj.class.should equal Hallon::Playlist
  end
  
  it "should not respond to #new" do
    lambda { Hallon::Playlist.new }.should raise_error
  end
  
  it "should have a length of 0" do
    @playlist.length.should be 0
  end
  
  it "should be loaded" do
    @playlist.loaded?.should equal true
  end
  
  it "should have a link" do
    link = @playlist.to_link
    link.to_str.should match "^spotify:(.*?):playlist:"
    link.type.should equal :playlist
  end
  
  it "can set collaboration flag" do
    @playlist.collaborative?.should equal false
    @playlist.collaborative = true
    @playlist.collaborative?.should equal true
  end
  
  it "can add new tracks" do
    track1 = Hallon::Link.new(TRACK_URI).to_obj
    length = @playlist.length
    @playlist.insert 0, track1, track1
    @playlist.length.should equal length + 2
  end

  it "should enforce a valid position when adding tracks" do
    lambda { @playlist.insert @playlist.length, Hallon::Link.new(TRACK_URI).to_obj }.should_not raise_error
    lambda { @playlist.insert @playlist.length + 1, Hallon::Link.new(TRACK_URI).to_obj }.should raise_error(ArgumentError)
  end
  
  it "can not add non-tracks" do
    lambda { @playlist.insert 0, @session }.should raise_error(TypeError)
  end
  
  it "can lookup tracks by position" do
    @playlist.at(0).name.should == Hallon::Link.new(TRACK_URI).to_obj.name
    @playlist.at(-1).name.should == @playlist.at(0).name
    @playlist.at(@playlist.length).should equal nil
  end
  
  it "can remove tracks" do
    @playlist.delete_at(0, @playlist.length).length.should equal 0
  end
  
  it "can checked for equality" do
    @playlist.should == @playlist
    @playlist.should_not == @session.playlists.at(1)
  end
  
  it "can be renamed" do
    name = "hanky panky wanky"
    @playlist.name.should_not == name
    @playlist.name = name
    @playlist.name.should == name
  end
  
  it "should have an owner" do
    @playlist.owner.should == @session.user
  end
end