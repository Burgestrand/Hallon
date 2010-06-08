require 'lib/hallon'
require File.expand_path('../config', __FILE__)

Dir.chdir(File.dirname(__FILE__))

# Globals
TRACK_URI = "spotify:track:4yJmwG2C1SDgcBbV50xI91"
PLAYLIST  = "rspec-" + Time.now.gmtime.strftime("%Y-%m-%d %H:%M:%S.#{Time.now.gmtime.usec}")

describe Hallon do
  it "has an up-to-date spotify library" do
    Hallon::API_VERSION.should == 4
  end
end

describe Hallon::Session, " before creation" do
  it "should be a singleton" do
    Hallon::Session.should_not respond_to(:new)
  end

  it "should require an application key" do
    lambda { Hallon::Session.instance }.should raise_error(ArgumentError)
  end

  it "should fail on an invalid application key" do
    lambda { Hallon::Session.instance('invalid') }.should raise_error(Hallon::Error)
  end
  
  it "should succeed with a valid application key" do
    lambda { Hallon::Session.instance APPKEY }.should_not raise_error
  end
end

describe Hallon::Session, " once created" do
  before :all do
    @session = Hallon::Session.instance
  end
  
  it "should not be logged in" do
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
  
  after :all do
    @session.logout
  end
  
  it "should validate playlist name length before creation" do
    # 0 < x < 256
    lambda { @container.add "" }.should raise_error(ArgumentError)
    lambda { @container.add("a" * 256) }.should raise_error(ArgumentError)
  end
  
  it "should validate playlist name contents before creation" do
    # Not only spaces
    lambda { @container.add " " }.should raise_error(ArgumentError)
  end
  
  it "can create new playlists" do
    length = @container.length
    playlist = @container.add PLAYLIST
    @container.length.should equal(length + 1)
    playlist.name.should == PLAYLIST
  end
  
  it "should be an enumerable collection" do
    @container.detect { |a| a.name == PLAYLIST }.should_not equal(nil)
  end
end

describe Hallon::Playlist, " when first created" do
  before :all do
    @session = Hallon::Session.instance.login(USERNAME, PASSWORD)
    @session.logged_in?.should equal(true)
    @playlist = @session.playlists.detect { |a| a.name == PLAYLIST }
  end
  
  after :all do
    @session.logout
  end
  
  it "should not respond to #new" do
    lambda { Hallon::Playlist.new }.should raise_error
  end
  
  it "should have a length of 0" do
    @playlist.length.should be 0
  end
  
  it "should be loaded" do
    @playlist.loaded?.should equal(true)
  end
  
  it "should have a link" do
    link = @playlist.link
    link.to_str.should match "^spotify:(.*?):playlist:"
    link.type.should equal(:playlist)
  end
  
  it "can set collaboration flag" do
    @playlist.collaborative?.should equal(false)
    @playlist.collaborative = true
    @playlist.collaborative?.should equal(true)
  end
  
  it "can add new tracks" do
    length = @playlist.length
    @playlist.push Hallon::Link.new(TRACK_URI).to_obj
    @playlist.length.should equal(length + 1)
  end
end

describe Hallon::Link do
  it "can parse Spotify URIs" do
    Hallon::Link.new(TRACK_URI).type.should equal(:track)
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
    Hallon::Link.new(TRACK_URI).id.should == '4yJmwG2C1SDgcBbV50xI91'
  end
end

describe Hallon::Track do
  before :all do
    @track = Hallon::Link.new(TRACK_URI).to_obj
  end
  
  it "can be spawned from a link" do
    @track.class.should equal Hallon::Track
  end
  
  it "should have a name" do
    @track.name.should == "The Boys Are Back In Town"
  end
end