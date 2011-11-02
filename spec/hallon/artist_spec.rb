# coding: utf-8
describe Hallon::Artist do
  it_should_behave_like "a Linkable object" do
    let(:spotify_uri) { "spotify:artist:3bftcFwl4vqRNNORRsqm1G" }
  end

  subject { Hallon::Artist.new(mock_artist) }

  it { should be_loaded }
  its(:name) { should eq "Jem" }
  its(:browse) do
    Hallon::Session.should_receive(:instance).exactly(2).times.and_return(session)
    Spotify.should_receive(:artistbrowse_create).exactly(2).times.and_return(mock_artistbrowse)

    should eq Hallon::ArtistBrowse.new(mock_artist)
  end

  describe "#portrait" do
    let(:link) { Hallon::Link.new(mock_image_uri) }

    specify "as an image" do
      Hallon::Session.should_receive(:instance).twice.and_return(session)

      subject.portrait.should eq Hallon::Image.new(mock_image_id)
    end

    specify "as a link" do
      subject.portrait(false).should eq Hallon::Link.new(mock_image_uri)
    end

    it "should be nil if an image is not available" do
      Spotify.should_receive(:artist_portrait).and_return(null_pointer)

      subject.portrait.should be_nil
    end
  end
end
