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
  end
  
  context "offline" do
    subject { Hallon::Session.new(Hallon::APPKEY) }
    its(:state) { should equal :logged_out }
  end
end