describe Hallon::Handler do
  describe "::build" do
    it "should build a correct handler from a module" do
      modul = Module.new do
        def i_am_defined?
          true
        end
      end
      
      handler = subject.build(modul)
      handler.should <= Hallon::Handler
      modul.should >= handler
    end
    
    it "should build a correct handler from a Handler-including class" do
      klass = Class.new { include Hallon::Handler }
      
      handler = subject.build(klass)
      handler.should <= Hallon::Handler
    end
    
    it "should raise an error from a non-Handler-including class" do
      klass = Class.new
      
      expect { subject.build(klass) }.to raise_error(ArgumentError)
    end
    
    it "should build a correct handler from nothing (ooh!)" do
      handler = subject.build(nil)
      handler.should <= Hallon::Handler
    end
    
    it "should allow the given block to override handlers" do
      handler = subject.build nil, proc { def moo; end }
      
      handler.should <= Hallon::Handler
      handler.instance_methods.should include :moo
    end
  end
end