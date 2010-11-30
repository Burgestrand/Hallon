describe Hallon::Session do
  describe "#new" do
    it "should require an application key" do
      expect { Hallon::Session.new }.to raise_error(ArgumentError)
    end
    
    it "should fail on an invalid application key" do
      expect { Hallon::Session.new('invalid') }.to raise_error(Hallon::Error)
    end
    
    it "should succeed with a valid application key" do
      expect { Hallon::Session.new(Hallon::APPKEY) }.to_not raise_error
    end
    
    # appkey, user agent, settings location, cache location
  end
end