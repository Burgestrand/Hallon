describe Hallon::Link do
  it_behaves_like "spotify objects" do
    subject { described_class }

    describe "::new" do
      it "should raise an ArgumentError on an invalid link" do
        expect { subject.new("") }.to raise_error(ArgumentError)
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
        Hallon::Link.new("spotify:user:burgestrand").to_str.should == "spotify:user:burgestrand"
      end
      
      it "should truncate if given a small maximum length" do
        Hallon::Link.new("spotify:user:burgestrand").to_str(7).should == "spotify"
      end
    end
  end
end