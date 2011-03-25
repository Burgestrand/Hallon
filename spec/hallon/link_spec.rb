describe Hallon::Link do
  has_requirement "pre-initialized Session" do
    subject { described_class }

    describe "::new" do
      it "should raise an ArgumentError on an invalid link" do
        expect { subject.new("omgwtfbbq") }.to raise_error(ArgumentError, /omgwtfbbq/)
      end

      it "should not raise error on valid links" do
        expect { subject.new("spotify:user:burgestrand") }.to_not raise_error
      end
    end
    
    describe "::valid?" do
      it "should be true for a valid link" do
        subject.valid?("spotify:user:burgestrand").should be_true
      end
      
      it "should be false for an invalid link" do
        subject.valid?("omgwtfbbq").should be_false
      end
    end
    
    describe "#to_str" do
      it "should return the Spotify URI as a string" do
        subject.new("spotify:user:burgestrand").to_str.should == "spotify:user:burgestrand"
      end
      
      it "should truncate if given a small maximum length" do
        subject.new("spotify:user:burgestrand").to_str(7).should == "spotify"
      end
    end
    
    describe "#length" do
      it { subject.new("spotify:user:burgestrand").length.should == "spotify:user:burgestrand".length }
    end
    
    describe "#type" do
      example_uris.each_pair do |uri, type|
        specify "#{uri} should equal #{type}" do
          Hallon::Link.new(uri).type.should equal type
        end
      end
    end
    
    describe "#to_s" do
      subject { Hallon::Link.new("spotify:user:burgestrand").to_s }
      it("should include the Spotify URI") { should include subject.to_str }
    end
  end
end