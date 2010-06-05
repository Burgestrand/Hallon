require 'lib/hallon'
require File.expand_path('../config', __FILE__)

Dir.chdir(File.dirname(__FILE__))

describe Hallon do
  it "has an up-to-date spotify library" do
    Hallon::API_VERSION.should == 4
  end
end

describe Hallon::Session, " before creation" do
  it "is a singleton" do
    Hallon::Session.should_not respond_to(:new)
  end

  it "requires an application key" do
    lambda { Hallon::Session.instance }.should raise_error(ArgumentError)
  end

  it "fails on an invalid application key" do
    lambda { Hallon::Session.instance('invalid') }.should raise_error(Hallon::Error)
  end
  
  it "works with a valid application key" do
    lambda { Hallon::Session.instance APPKEY }.should_not raise_error
  end
end

describe Hallon::Session, " once created" do
  before :all do
    @session = Hallon::Session.instance
  end
  
  it "is not logged in" do
    @session.logged_in?.should equal(false)
  end
  
  it "can log in" do
    @session.logged_in?.should equal(false)
    @session.login(USERNAME, PASSWORD)
    @session.logged_in?.should equal(true)
  end
  
  it "can log out" do
    @session.logged_in?.should equal(true)
    @session.logout
    @session.logged_in?.should equal(false)
  end
end

describe Hallon::PlaylistContainer do
  before :all do
    @session = Hallon::Session.instance.login(USERNAME, PASSWORD)
    @session.logged_in?.should equal(true)
    @container = @session.playlists
  end
  
  it "validates playlist name before creation" do
    # Not only spaces
    lambda { @container.add " " }.should raise_error(ArgumentError)
    
    # 0 < x < 256
    lambda { @container.add "" }.should raise_error(ArgumentError)
    lambda { @container.add("a" * 256) }.should raise_error(ArgumentError)
  end
  
  it "can create new playlists" do
    length = @container.length
    playlist = @container.add "rspec"
    @container.length.should equal(length + 1)
    playlist.name.should == "rspec"
  end
end

describe Hallon::Playlist, " when first created" do
  before :all do
    @playlist = Hallon::Session.instance.playlists.add "omgwtfbbq"
  end
  
  it "has a length of 0" do
    @playlist.length.should be 0
  end
end

describe Hallon::Link do
  before :all do
    @uri = "spotify:track:4yJmwG2C1SDgcBbV50xI91"
  end
  
  it "can parse Spotify URIs" do
    Hallon::Link.new(@uri).type.should equal(:track)
  end
  
  it "can render into Spotify URIs" do
    Hallon::Link.new(@uri).to_str.should == @uri
  end
  
  it "can be compared with other Spotify URIs" do
    @link = Hallon::Link.new(@uri)
    @uri.should == @link
    @link.should == Hallon::Link.new(@uri)
  end
end