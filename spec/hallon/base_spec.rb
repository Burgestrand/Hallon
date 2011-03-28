describe Hallon::Base do
  subject do
    klass = Class.new do
      include Hallon::Base
    end
    
    obj = klass.new
    obj.instance_eval do
      on(:fired_event) { :fired! }
    end
    obj
  end
  
  its(:public_methods) { should include :on }

  describe "#on" do
    it { should respond_to :on_fired_event }
    
    it "should define methods without instance_eval" do
      subject.on(:method_call) {}
      should respond_to :on_method_call
    end
  end
end