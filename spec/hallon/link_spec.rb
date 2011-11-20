describe Hallon::Link do
  subject { Hallon::Link.new("spotify:user:burgestrand") }

  context "class methods" do
    describe "::new" do
      it "should raise an ArgumentError on an invalid link" do
        expect { Hallon::Link.new("omgwtfbbq") }.to raise_error(ArgumentError, /omgwtfbbq/)
      end

      it "should not raise error on valid links" do
        expect { Hallon::Link.new("spotify:user:burgestrand") }.to_not raise_error
      end

      it "should accept an FFI pointer" do
        expect { Hallon::Link.new(Spotify::Pointer.new(null_pointer, :link, false)) }.to raise_error(ArgumentError, /is not a valid spotify link/)
      end

      it "should raise an error when no session instance is about" do
        # this is due to a bug in libspotify, it will segfault otherwise
        Hallon::Session.stub(:instance?).and_return(false)
        expect { Hallon::Link.new("spotify:user:burgestrand") }.to raise_error /session/i
      end
    end

    describe "::valid?" do
      it "should be true for a valid link" do
        Hallon::Link.valid?("spotify:user:burgestrand").should be_true
      end

      it "should be false for an invalid link" do
        Hallon::Link.valid?("omgwtfbbq").should be_false
      end
    end
  end

  describe "#to_str" do
    it "should return the Spotify URI as a string" do
      subject.to_str.should == "spotify:user:burgestrand"
    end

    it "should truncate if given a small maximum length" do
      subject.to_str(7).should == "spotify"
    end
  end

  describe "#to_url" do
    it "should return the correct http URL" do
      subject.to_url.should == "http://open.spotify.com/user/burgestrand"
    end
  end

  describe "#length" do
    it { subject.length.should == "spotify:user:burgestrand".length }
  end

  describe "#type" do
    example_uris.each_pair do |uri, type|
      specify "#{uri} should equal #{type}" do
        Hallon::Link.new(uri).type.should equal type
      end
    end
  end

  describe "#to_s" do
    it("should include the Spotify URI") do
      subject.to_s.should include subject.to_str
    end
  end

  describe "#==" do
    it "should compare using #to_str" do
      obj = Object.new
      obj.should_receive(:to_str).and_return(subject.to_str)

      subject.should eq obj
    end

    it "should not fail when #to_str is unavailable" do
      object = Object.new
      object.should_not respond_to :to_str
      subject.should_not eq object
    end

    it "should compare underlying pointers if #to_str is unavailable" do
      object = Hallon::Link.new(subject.pointer)

      def object.respond_to?(o)
        return false if o == :to_str
        super
      end

      subject.should eq object
    end
  end
end
