require 'hallon'

describe Hallon do
  it "should be up to date" do
    Hallon::API_VERSION.should == 4
  end

  describe Hallon::Session do
    before :all do
      @appkey = IO.read 'spotify_appkey.key'
    end
    
    it "should be a singleton" do
      Hallon::Session.should_not respond_to(:new)
    end

    it "should require an application key" do
      lambda { Hallon::Session.instance }.should raise_error(ArgumentError)
    end

    it "should only accept a valid application key" do
      lambda { Hallon::Session.instance 'invalid' }.should raise_error(Hallon::Error)
      lambda { Hallon::Session.instance @appkey }.should_not raise_error
    end
    
    it "should not accept arguments after instantiation" do
      lambda { Hallon::Session.instance @appkey }.should raise_error(ArgumentError)
      lambda { Hallon::Session.instance }.should_not raise_error
    end
  end
end