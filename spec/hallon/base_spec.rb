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
  
  its(:private_methods) { should include :on }

  describe "#on" do
    it { should respond_to :on_fired_event }
  end
end