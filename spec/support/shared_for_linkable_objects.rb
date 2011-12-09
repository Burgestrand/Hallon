# coding: utf-8
shared_examples_for "a Linkable object" do
  describe "instantiation" do
    let(:spotify_pointer) do
      ptr_type    = Hallon::Link.new(spotify_uri).type
      ptr_type    = :user if ptr_type == :profile
      ffi_pointer = Spotify.registry_find(spotify_uri[/[^#]+/]) # up to pound sign for track#offset
      Spotify::Pointer.new(ffi_pointer, ptr_type, false)
    end

    it "should work with a string URI" do
      expect { described_class.new(spotify_uri) }.to_not raise_error
    end

    it "should fail with an invalid spotify pointer" do
      expect { described_class.new("i_am_invalid_uri") }.to raise_error(ArgumentError, /could not be converted to a spotify \w+ pointer/)
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
    subject { described_class.new(spotify_uri) }

    it "should return a valid link" do
      subject.to_link.should eq Hallon::Link.new(spotify_uri)
    end
  end
end
