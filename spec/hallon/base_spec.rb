describe Hallon::Base do
  subject do
    Hallon::Base.new do
      on(:fired_event) { :fired! }
    end
  end
  
  its(:methods) { should include :on }

  describe "#on" do
    it { should respond_to :on_fired_event }
  end
end