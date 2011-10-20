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
    let(:link) { Hallon::Link.new("spotify:image:3ad93423add99766e02d563605c6e76ed2b0e450") }
    let(:link_pointer) { FFI::Pointer.new(link.pointer.address) }
    let(:link_spotify_pointer) { Spotify::Pointer.new(link_pointer, :link, false) }

    specify "as an image" do
      Spotify.should_receive(:link_create_from_artist_portrait).with(subject.pointer).and_return(link_pointer)
      Hallon::Session.should_receive(:instance).twice.and_return(session)

      subject.portrait.should eq Hallon::Image.new(link_spotify_pointer)
    end

    specify "as a link" do
      Spotify.should_receive(:link_create_from_artist_portrait).with(subject.pointer).and_return(link_pointer)

      subject.portrait(false).should eq link
    end
  end
end
