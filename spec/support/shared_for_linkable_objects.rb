# coding: utf-8
shared_examples_for "a Linkable object" do
  subject { described_class.new(spotify_uri) }

  describe "instantiation" do
    let(:spotify_pointer) do
      ptr_type    = Hallon::Link.new(spotify_uri).type
      ptr_type    = :user if ptr_type == :profile
      ptr_class   = Spotify.const_get(ptr_type.to_s.sub(/\A\w/) { |x| x.upcase })
      ffi_pointer = Spotify.mock_registry_find(spotify_uri[/[^#]+/]) # up to pound sign for track#offset
      ptr_class.new(ffi_pointer)
    end

    it "should work with a string URI" do
      expect { described_class.new(spotify_uri) }.to_not raise_error
    end

    it "should fail with an invalid spotify pointer" do
      expect { described_class.new("i_am_invalid_uri") }.to raise_error(ArgumentError)
    end

    it "should work with a Link object" do
      expect { described_class.new(Hallon::Link.new(spotify_uri)) }.to_not raise_error
    end

    it "should work with a spotify pointer" do
      expect { described_class.new(spotify_pointer) }.to_not raise_error
    end

    it "should work with a custom object" do
      expect { described_class.new(custom_object) }.to_not raise_error
    end if defined?(custom_object)
  end

  describe "#to_link" do
    it "should return a valid link" do
      subject.to_link.should eq Hallon::Link.new(spotify_uri)
    end
  end

  describe "#to_str" do
    it "should return the spotify URI for this object" do
      subject.to_str.should eq spotify_uri
    end

    it "should return an empty string if #to_link fails" do
      subject.should_receive(:to_link).and_return(nil)
      subject.to_str.should eq ""
    end
  end

  describe "#===" do
    it "should compare the objects by their links if both are Linkable" do
      mock = double
      mock.stub(:to_link).and_return(subject.to_link)

      (subject === mock).should be_true
    end
  end
end
