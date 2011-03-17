describe Hallon::Error do
  subject { described_class }
  
  it { should <= RuntimeError }
  
  describe "::disambiguate" do
    it "should not fail on invalid numbers" do
      subject.disambiguate(10000).should eq [-1, nil]
    end
    
    it "should not fail on invalid symbols" do
      subject.disambiguate(:fail).should eq [-1, nil]
    end
  end
  
  describe "::explain" do
    it { subject.explain(0).should eq 'No error' }
    it { subject.explain(-1).should eq 'invalid error code' }
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