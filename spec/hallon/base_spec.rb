describe Hallon::Base do
  subject do 
    Class.new do
      include Hallon::Base
    end
  end
  
  before(:each) { @subject = subject.new }
  
  its(:instance_methods) { should include :on }

  describe "#on" do
    it "should define the given method with an on_ prefix" do
      @subject.on(:fired_event) {}
      @subject.should respond_to :on_fired_event
    end
  end
  
  describe "#protecting_handlers" do
    it "should call the given block and return its value" do
      @subject.protecting_handlers do
        "was called"
      end.should eq "was called"
    end
    
    it "should restore the previous handler on exit" do
      @subject.on(:before_block) { "unchanged" }
      
      @subject.protecting_handlers do
        @subject.on(:before_block) { "changed" }
        @subject.on_before_block.should eq "changed"
      end
      
      @subject.on_before_block.should eq "unchanged"
    end
    
    specify "#on should still work properly afterwards" do
      @subject.protecting_handlers do
        # nothing!
      end
      
      @subject.on(:after_block) { |*args| args }
      @subject.on_after_block(1, 2).should eq [1, 2]
    end
  end
end