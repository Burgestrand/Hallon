# coding: utf-8
describe Hallon::Artist do
  let(:artist) do
    Hallon::Artist.new(mock_artists[:default])
  end

  let(:empty_artist) do
    Hallon::Artist.new(mock_artists[:empty])
  end

  specify { artist.should be_a Hallon::Loadable }

  it_should_behave_like "a Linkable object" do
    let(:spotify_uri) { "spotify:artist:3bftcFwl4vqRNNORRsqm1G" }
  end

  describe "#loaded?" do
    it "returns true when the artist is loaded" do
      artist.should be_loaded
    end
  end

  describe "#name" do
    it "returns the artist’s name" do
      artist.name.should eq "Jem"
    end

    it "returns an empty string if the artist is not loaded" do
      empty_artist.name.should be_empty
    end
  end

  describe "#browse" do
    it "should return an artist browsing object" do
      artist.browse.should eq Hallon::ArtistBrowse.new(mock_artist)
    end

    it "should default to full browsing" do
      Hallon::ArtistBrowse.should_receive(:new).with(artist.pointer, :full)
      artist.browse
    end

    it "should pass the browsing type along when creating the artist browsing object" do
      Hallon::ArtistBrowse.should_receive(:new).with(artist.pointer, :no_tracks)
      artist.browse(:no_tracks)
    end
  end

  describe "#portrait" do
    it "should be an image if it exists" do
      artist.portrait.should eq Hallon::Image.new(mock_image_id)
    end

    it "should be nil if an image is not available" do
      empty_artist.portrait.should be_nil
    end
  end

  describe "#portrait_link" do
    it "should be a link if it exists" do
      artist.portrait_link.should eq Hallon::Link.new(mock_image_uri)
    end

    it "should be nil if an image is not available" do
      empty_artist.portrait_link.should be_nil
    end
  end
end
