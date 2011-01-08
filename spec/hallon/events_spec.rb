describe Hallon::Events do
  describe "::build_handler" do
    before(:all) do
      Hallon::Events.const_set("NilClass", Module.new)
    end
    
    it "should build a correct handler from a module" do
      modul = Module.new do
        def i_am_defined?
          true
        end
      end
      
      handler = subject.build_handler(nil, modul)
      handler.should be_a Hallon::Events
      handler.should be_a modul
    end
    
    it "should build a correct handler from a Events-including class" do
      klass = Class.new { include Hallon::Events }
      
      handler = subject.build_handler(nil, klass)
      handler.should be_a Hallon::Events
    end
    
    it "should raise an error from a non-Events-including class" do
      klass = Class.new
      
      expect { subject.build_handler(nil, klass) }.to raise_error(ArgumentError)
    end
    
    it "should build a correct handler from nothing (ooh!)" do
      handler = subject.build_handler(nil)
      handler.should be_a Hallon::Events
    end
    
    it "should allow the given block to override handlers" do
      handler = subject.build_handler(nil) do
        def initialize(whatever)
          self.subject = "moo"
        end
      end
      
      handler.should be_a Hallon::Events
      handler.subject.should == "moo"
    end
    
    it "should correctly look up a handler based on the passed subject" do
      Session = Class.new
      
      handler = subject.build_handler(Session.new)
      handler.should be_a Hallon::Events
      handler.should be_a Hallon::Events::Session
    end
  end
end