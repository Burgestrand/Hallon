describe Hallon::Link do
  let(:link) do
    Hallon::Link.new("spotify:user:burgestrand")
  end

  describe ".new" do
    it "should raise an ArgumentError on an invalid link" do
      expect { Hallon::Link.new("omgwtfbbq") }.to raise_error(ArgumentError, /omgwtfbbq/)
    end

    it "should not raise error on valid links" do
      expect { Hallon::Link.new("spotify:user:burgestrand") }.to_not raise_error
    end

    it "should raise an error given a null pointer" do
      expect { Hallon::Link.new(Spotify::Pointer.new(null_pointer, :link, false)) }.to raise_error(ArgumentError)
    end

    it "should raise an error when no session instance is about" do
      # this is due to a bug in libspotify, it will segfault otherwise
      Hallon::Session.stub(:instance?).and_return(false)
      expect { Hallon::Link.new("spotify:user:burgestrand") }.to raise_error(Hallon::NoSessionError)
    end

    it "should accept any object that supplies a #to_link method" do
      link = Hallon::Link.new("spotify:user:burgestrand")

      to_linkable = double
      to_linkable.should_receive(:to_link).and_return(link)

      Hallon::Link.new(to_linkable).should eq link
    end
  end

  describe ".valid?" do
    it "should be true for a valid link" do
      Hallon::Link.valid?("spotify:user:burgestrand").should be_true
    end

    it "should be false for an invalid link" do
      Hallon::Link.valid?("omgwtfbbq").should be_false
    end

    it "raises an error when no session has been initialized" do
      # this is due to a bug in libspotify, it will segfault otherwise
      Hallon::Session.stub(:instance?).and_return(false)
      expect { Hallon::Link.valid?("omgwtfbbq") }.to raise_error(Hallon::NoSessionError)
    end
  end

  describe "#to_str" do
    it "should return the Spotify URI as a string" do
      link.to_str.should == "spotify:user:burgestrand"
    end

    it "should truncate if given a small maximum length" do
      link.to_str(7).should == "spotify"
    end

    it "should be in UTF-8 encoding" do
      link.to_str.encoding.should eq Encoding::UTF_8
    end
  end

  describe "#to_url" do
    it "should return the correct http URL" do
      link.to_url.should == "http://open.spotify.com/user/burgestrand"
    end
  end

  describe "#length" do
    it "returns the image length" do
      link.length.should == "spotify:user:burgestrand".length
    end
  end

  describe "#type" do
    example_uris.each_pair do |uri, type|
      specify "#{uri} should equal #{type}" do
        Hallon::Link.new(uri).type.should equal type
      end
    end
  end

  describe "#to_s" do
    it "includes the image URI" do
      link.to_s.should include link.to_uri
    end
  end

  describe "#==" do
    it "should compare using #to_str *if* other is a Link" do
      objA = double
      objA.should_not_receive(:to_str)

      objB = Hallon::Link.new(link.to_str)
      objB.should_receive(:pointer).and_return(null_pointer)
      objB.should_receive(:to_str).and_return(link.to_str)

      link.should_not eq objA
      link.should eq objB
    end

    it "should compare underlying pointers if #to_str is unavailable" do
      object = Hallon::Link.new(link.pointer)

      def object.respond_to?(o)
        return false if o == :to_str
        super
      end

      link.should eq object
    end
  end

  describe "#pointer" do
    it "should raise an error if the expected type is not the same as requested" do
      expect { Hallon::Link.new("spotify:user:burgestrand:starred").pointer(:profile) }.to raise_error(ArgumentError)
    end

    it "should not raise an error if the expected type is :playlist but real type is starred" do
      expect { Hallon::Link.new("spotify:user:burgestrand:starred").pointer(:playlist) }.to_not raise_error
    end

    it "should not raise an error if the expected type and type matches" do
      expect { Hallon::Link.new("spotify:user:burgestrand").pointer(:profile) }.to_not raise_error
    end
  end
end
