require 'lib/hallon'
require File.expand_path('../config', __FILE__)

Dir.chdir(File.dirname(__FILE__))

describe Hallon do
  it "should have an up-to-date spotify library" do
    Hallon::API_VERSION.should == 4
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
    
    it "should be able to log in" do
      @session.logged_in?.should equal(false)
      @session.login(USERNAME, PASSWORD)
      @session.logged_in?.should equal(true)
    end
    
    it "should be able to log out" do
      @session.logged_in?.should equal(true)
      @session.logout
      @session.logged_in?.should equal(false)
    end
  end
  
  describe Hallon::Playlist do
    before :all do
      @session = Hallon::Session.instance.login(USERNAME, PASSWORD)
      @session.logged_in?.should equal(true)
      @container = @session.playlists
    end
    
    it "should validate playlist name before creation" do
      # Not only spaces
      lambda { @container.add " " }.should raise_error(ArgumentError)
      
      # 0 < x < 256
      lambda { @container.add "" }.should raise_error(ArgumentError)
      lambda { @container.add("a" * 256) }.should raise_error(ArgumentError)
    end
    
    it "should be possible to create new playlists" do
      length = @container.length
      @playlist = @container.add "rspec"
      @container.length.should equal(length + 1)
      @playlist.name.should == "rspec"
    end
  end
end