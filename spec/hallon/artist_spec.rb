# coding: utf-8
describe Hallon::Artist do
  it { should be_a Hallon::Loadable }

  it_should_behave_like "a Linkable object" do
    let(:spotify_uri) { "spotify:artist:3bftcFwl4vqRNNORRsqm1G" }
  end

  let(:artist) { Hallon::Artist.new(mock_artist) }
  subject { artist }

  it { should be_loaded }
  its(:name) { should eq "Jem" }

  describe "#browse" do
    it "should return an artist browsing object" do
      mock_session(2) { subject.browse.should eq Hallon::ArtistBrowse.new(mock_artist) }
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
    let(:link) { Hallon::Link.new(mock_image_uri) }

    it "should be nil if an image is not available" do
      Spotify.should_receive(:artist_portrait).and_return(null_pointer)
      artist.portrait.should be_nil
    end

    it "should be an image if it exists" do
      stub_session { artist.portrait.should eq Hallon::Image.new(mock_image_id) }
    end
  end

  describe "#portrait_link" do
    it "should be nil if an image is not available" do
      Spotify.should_receive(:link_create_from_artist_portrait).and_return(null_pointer)
      artist.portrait_link.should be_nil
    end

    it "should be a link if it exists" do
      artist.portrait_link.should eq Hallon::Link.new(mock_image_uri)
    end
  end
end
