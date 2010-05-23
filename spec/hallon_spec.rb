require 'hallon'

describe Hallon do
  it "should have an up-to-date spotify library" do
    Hallon::API_VERSION.should == 4
  end

  describe Hallon::Session do
    it "should be a singleton" do
      Hallon::Session.should_not respond_to(:new)
    end

    it "should require an application key" do
      lambda { Hallon::Session.instance }.should raise_error(ArgumentError)
    end

    it "should only accept a valid application key" do
      lambda { Hallon::Session.instance 'invalid' }.should raise_error(Hallon::Error)
      lambda { Hallon::Session.instance APPKEY }.should_not raise_error
    end
    
    it "should not accept arguments after instantiation" do
      lambda { Hallon::Session.instance APPKEY }.should raise_error(ArgumentError)
      lambda { Hallon::Session.instance }.should_not raise_error
    end
        
    it "should be capable of logging a user in" do
      Hallon::Session.instance.logged_in?.should equal(false)
      lambda { Hallon::Session.instance.login USERNAME, PASSWORD }.should_not raise_error
      Hallon::Session.instance.logged_in?.should equal(true)
    end
  end
end