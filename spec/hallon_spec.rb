require 'hallon'

describe Hallon do
  it "should be up to date" do
    Hallon::API_VERSION.should == 4
  end

  describe Hallon::Error do
    it "should translate error codes" do
      Hallon::Error.message(1).should == 'Invalid library version'
    end
  end
  
  describe Hallon::Session do
    before :all do
      @appkey = IO.read 'spotify_appkey.key'
    end

    it "should require an application key" do
      lambda { Hallon::Session.new }.should raise_error(ArgumentError)
    end

    it "should fail with an invalid application key" do
      lambda { Hallon::Session.new 'invalid' }.should raise_error(Hallon::Error)
    end

    it "should succeed with a valid application key" do
      lambda { Hallon::Session.new @appkey }.should_not raise_error
    end
  end
end