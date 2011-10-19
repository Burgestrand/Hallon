shared_examples_for "a Linkable object" do
  describe "instantiation" do
    it "should work with a string URI" do
      expect { described_class.new(valid_string_uri) }.to_not raise_error
    end

    it "should fail with an invalid spotify pointer" do
      expect { described_class.new("i_am_invalid_uri") }.to raise_error(ArgumentError, /not a valid spotify \w+ URI or pointer/)
    end

    it "should work with a Link object" do
      expect { described_class.new(Hallon::Link.new(valid_string_uri)) }.to_not raise_error
    end

    it "should work with a custom object" do
      pending("does not support custom object instantiation", :unless => defined?(custom_object))
      expect { described_class.new(custom_object) }.to_not raise_error
    end
  end

  describe "#to_link" do
    subject { described_class.new(valid_string_uri) }

    it "should return a valid link" do
      subject.to_link.should eq Hallon::Link.new(valid_string_uri)
    end
  end
end
