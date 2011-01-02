describe Hallon::Error do
  subject { described_class }
  
  it { should <= StandardError }
  
  describe "::explain" do
    it { subject.explain(0).should be_a String }
    
    it "should not fail when given an invalid number" do
      subject.explain(-1).should be_a String
    end
  end
  
  describe "::maybe_raise" do
    it "should not raise error when given 0 as error code" do
      expect { subject.maybe_raise(0) }.to_not raise_error
    end
    
    it "should raise error when given non-0 as error code" do
      expect { subject.maybe_raise(1) }.to raise_error(Hallon::Error)
    end
  end
end