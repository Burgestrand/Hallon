require 'ostruct' # https://github.com/rspec/rspec-core/issues/issue/264

describe Hallon::Session do
  def session
    @options = {:user_agent => "RSpec", :settings_path => "tmp", :cache_path => "tmp/cache" }
    Hallon::Session.instance(Hallon::APPKEY, @options)
  end
  
  subject { session }
  it { Hallon::Session.should_not respond_to :new }
  
  describe "#instance" do
    it "should require an application key" do
      expect { Hallon::Session.instance }.to raise_error(ArgumentError)
    end
    
    it "should fail on an invalid application key" do
      expect { Hallon::Session.instance('invalid') }.to raise_error(Hallon::Error)
    end
    
    it "should not spawn event handling threads on failure" do
      threads = Thread.list.length
      expect { Hallon::Session.instance('invalid') }.to raise_error(Hallon::Error)
      threads.should equal Thread.list.length
    end
    
    it "should fail on a huge user agent (> 255 characters)" do
      expect { Hallon::Session.instance(Hallon::APPKEY, :user_agent => 'a' * 300) }.
        to raise_error(ArgumentError)
    end
    
    it "should succeed when given proper parameters" do
      expect { subject }.to_not raise_error
    end
  end
  
  context "once instantiated" do
    describe "appkey" do
      it "should == Hallon::APPKEY" do subject.appkey.should == Hallon::APPKEY end
    end
    
    describe "options" do
      subject { session.options }
      its([:user_agent]) { should == "RSpec" }
      its([:settings_path]) { should == "tmp" }
      its([:cache_path]) { should == "tmp/cache" }
    end
    
    describe "#merge_defaults" do
      it "should return the defaults if no options given" do
        session.send(:merge_defaults, nil).should be_a Hash # values not important
      end
      
      it "should allow given options to override defaults" do
        session.send(:merge_defaults, :user_agent => "Cow")[:user_agent].should == "Cow"
      end
    end
    
    describe "#process_events" do
      it "should return the timeout" do
        subject.process_events.should be_a Fixnum
      end
    end
    
    describe "#logout" do
      it "should check logged in status" do
        subject.should_receive(:logged_in?).once
        expect { subject.logout! }.to_not raise_error
      end
    end
  end
end