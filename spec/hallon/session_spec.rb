describe Hallon::Session do
  describe "#new" do
    it "should require an application key" do
      expect { Hallon::Session.new }.to raise_error(ArgumentError)
    end
    
    it "should fail on an invalid application key" do
      expect { Hallon::Session.new('invalid') }.to raise_error(Hallon::Error)
    end
  end
  
  context "once instantiated" do
    before :all do
      @session = Hallon::Session.new(Hallon::APPKEY, "Hallon", "tmp", "tmp/cache")
    end
    
    describe '#user_agent' do
      specify { @session.user_agent.should == "Hallon" }
    end
    
    describe '#settings_path' do
      specify { @session.settings_path.should == "tmp" }
    end
    
    describe '#cache_path' do
      specify { @session.cache_path.should == "tmp/cache" }
    end
    
    describe '#state' do
      specify { @session.state.should equal :logged_out }
    end
  end
end