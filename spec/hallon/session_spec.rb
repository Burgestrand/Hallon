describe Hallon::Session do
  it { Hallon::Session.should_not respond_to :new }
  
  describe "#instance" do
    it "should require an application key" do
      expect { Hallon::Session.instance }.to raise_error(ArgumentError)
    end
    
    it "should fail on an invalid application key" do
      expect { Hallon::Session.instance('invalid') }.to raise_error(Hallon::Error)
    end
    
    it "should succeed when given proper parameters" do
      expect { Hallon::Session.instance(Hallon::APPKEY, "Hallon", "tmp", "tmp/cache") }.to_not raise_error
    end
  end
  
  context "once instantiated" do
    subject { Hallon::Session.instance(Hallon::APPKEY, "Hallon", "tmp", "tmp/cache") }
    
    # The appkey is long, to avoid displaying it in the console we do like this.
    describe "application_key" do
      it "should == Hallon::APPKEY" do subject.application_key.should == Hallon::APPKEY end
    end
    
    its(:user_agent) { should == "Hallon" }
    its(:settings_path) { should == "tmp" }
    its(:cache_path) { should == "tmp/cache" }
    its(:state) { should == :logged_out }
    
    describe "#process_events" do
      it "should return the timeout" do
        subject.process_events.should be_a Fixnum
      end
    end
  end
end