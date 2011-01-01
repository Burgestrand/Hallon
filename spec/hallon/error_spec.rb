describe Hallon::Error do
  subject { Hallon::Error }
  
  it { should <= StandardError }
  
  describe "::explain" do
    it { subject.explain(0).should be_a String }
    
    it "should not fail when given an invalid number" do
      Hallon::Error.explain(-1).should be_a String
    end
  end
end