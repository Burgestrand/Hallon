# coding: utf-8
#
describe Hallon::Album do
  let(:album) do
    Hallon::Album.new(mock_albums[:default])
  end

  let(:empty_album) do
    Hallon::Album.new(mock_albums[:empty])
  end

  specify { album.should be_a Hallon::Loadable }

  it_should_behave_like "a Linkable object" do
    let(:spotify_uri) { "spotify:album:1xvnWMz2PNFf7mXOSRuLws" }
  end

  describe ".types" do
    subject { Hallon::Album.types }

    it { should be_an Array }
    it { should include :single }
  end

  describe "#name" do
    it "returns the album’s name" do
      album.name.should eq "Finally Woken"
    end

    it "returns an empty string if the album is not loaded" do
      empty_album.name.should be_empty
    end
  end

  describe "#release_year" do
    it "returns the album’s release year" do
      album.release_year.should eq 2004
    end
  end

  describe "#type" do
    it "returns the album’s type" do
      album.type.should eq :single
    end
  end

  describe "#browse" do
    it "returns the album’s browser object" do
      album.browse.should eq Hallon::AlbumBrowse.new(album)
    end
  end

  describe "#available?" do
    it "returns true when the album is available" do
      album.should be_available
    end
  end

  describe "#loaded?" do
    it "returns true when the album is loaded" do
      album.should be_loaded
    end
  end

  describe "artist" do
    it "should be an artist if it exists" do
      album.artist.should eq Hallon::Artist.new(mock_artist)
    end

    it "should be nil if there is no artist" do
      empty_album.artist.should be_nil
    end
  end

  describe "#cover" do
    it "should be an image if it exists" do
      album.cover.should eq Hallon::Image.new(mock_image_id)
    end

    it "should be nil if there is no image" do
      empty_album.cover.should be_nil
    end
  end

  describe "#cover_link" do
    it "should be a link if it exists" do
      album.cover_link.should eq Hallon::Link.new("spotify:image:3ad93423add99766e02d563605c6e76ed2b0e400")
    end

    it "should be nil if there is no image" do
      empty_album.cover_link.should be_nil
    end
  end
end
