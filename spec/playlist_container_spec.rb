describe Hallon::PlaylistContainer do
  before :all do
    @session = Hallon::Session.instance.login(USERNAME, PASSWORD)
    @session.logged_in?.should equal true
    @container = @session.playlists
  end
  
  after :all do
    @session.logout
  end
  
  it "should validate playlist name length before creation" do
    # 0 < x < 256
    lambda { @container.push "" }.should raise_error(ArgumentError)
    lambda { @container.push("a" * 256) }.should raise_error(ArgumentError)
  end
  
  it "should validate playlist name contents before creation" do
    # Not only spaces
    lambda { @container.push " " }.should raise_error(ArgumentError)
  end
  
  it "can create new playlists" do
    length = @container.length
    playlist = @container.push PLAYLIST
    @container.length.should equal length + 1
    playlist.name.should == PLAYLIST
  end
  
  it "can remove playlists" do
    length = @container.length
    playlist = @container.detect { |a| a.name == PLAYLIST }
    playlist.should_not equal nil
    @container.delete playlist
    @container.length.should equal length - 1
  end
  
  it "can add existing playlists" do
    length = @container.length
    playlist = Hallon::Link.new(PLAYLIST_URI).to_obj
    pl = @container.push playlist
    @container.length.should == length + 1
    pl.should == playlist
    @container.delete pl
  end
  
  it "can lookup playlists by position" do
    @container.at([0, @container.length - 1].max).name.should == @container.at(-1).name
    @container.at(0).should == @container[0]
  end
end