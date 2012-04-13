describe Hallon::Error do
  subject { described_class }

  it { should <= RuntimeError }

  describe ".disambiguate" do
    it "should not fail on invalid numbers" do
      subject.disambiguate(10000).should eq [-1, nil]
    end

    it "should not fail on invalid symbols" do
      subject.disambiguate(:fail).should eq [-1, nil]
    end
  end

  describe ".explain" do
    it "should work properly given an integer" do
      subject.explain(0).should eq 'sp_error: 0'
    end

    it "should work properly given a symbol" do
      subject.explain(:bad_api_version).should eq 'sp_error: 1'
    end
  end

  describe ".maybe_raise" do
    it "should not raise error when given 0 as error code" do
      expect { subject.maybe_raise(0) }.to_not raise_error
    end

    it "should raise error when given non-0 as error code" do
      expect { subject.maybe_raise(1) }.to raise_error(Hallon::Error)
    end

    it "should return the error symbol if it's ok" do
      subject.maybe_raise(0).should eq :ok
    end

    # to account for the following case:
    # session.wait_for(:timeout) { |param| Hallon::Error.maybe_raise(param) }
    it "should return nil when the error is nil" do
      subject.maybe_raise(nil).should eq nil
    end

    it "should return nil if the given symbol is also ignored" do
      subject.maybe_raise(:is_loading, ignore: :is_loading).should eq nil
    end
  end

  describe ".table" do
    it "should return a hash of symbol to integer" do
      Hallon::Error.table[:ok].should eq 0
    end
  end
end
