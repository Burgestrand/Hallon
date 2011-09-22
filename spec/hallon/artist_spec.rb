# coding: utf-8
describe Hallon::Artist do
  subject { Hallon::Artist.new(mock_artist) }

  it { should be_loaded }
  its(:name) { should eq "Jem" }
  its(:browse) do
    Hallon::Session.should_receive(:instance).exactly(2).times.and_return(session)
    Spotify.should_receive(:artistbrowse_create).exactly(2).times.and_return(mock_artistbrowse)

    should eq Hallon::ArtistBrowse.new(mock_artist)
  end

  describe "#portrait" do
    let(:link) { Hallon::Link.new("spotify:image:c78f091482e555bd2ffacfcd9cbdc0714b221663") }
    let(:link_pointer) { FFI::Pointer.new(link.pointer.address) }

    before do
      Hallon::Link.new(link_pointer).should eq link
      Spotify.should_receive(:link_create_from_artist_portrait).with(subject.pointer).and_return(link_pointer)
    end

    specify "as an image" do
      Hallon::Session.should_receive(:instance).twice.and_return(session)
      subject.portrait.should eq Hallon::Image.new(link_pointer)
    end

    specify "as a link" do
      subject.portrait(false).should eq link
    end
  end
end
