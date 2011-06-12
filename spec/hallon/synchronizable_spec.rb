describe Hallon::Synchronizable do
  subject do
    Class.new { include described_class }.new
  end

  describe "#synchronize" do
    it "should not deadlock when called recursively in itself" do
      expect do
        subject.synchronize { @subject.synchronize {} }
      end.to_not raise_error
    end
  end

  describe "#new_cond" do
    it "should give us a new condition variable" do
      subject.new_cond.should be_a Monitor::ConditionVariable
    end
  end
end
