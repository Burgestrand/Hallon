# coding: utf-8
describe Hallon::Album do
  it_should_behave_like "a Linkable object" do
    let(:spotify_uri) { "spotify:album:1xvnWMz2PNFf7mXOSRuLws" }
  end

  subject { Hallon::Album.new(mock_album) }

  its(:name) { should eq "Finally Woken" }
  its(:year) { should be 2004 }
  its(:type) { should be :single }

  its(:browse) do
    mock_session do
      Spotify.should_receive(:albumbrowse_create).exactly(2).times.and_return(mock_albumbrowse)
      should eq Hallon::AlbumBrowse.new(mock_album)
    end
  end

  it { should be_available }
  it { should be_loaded }

  describe "artist" do
    it "should be nil if there is no artist" do
      Spotify.should_receive(:album_artist).and_return(null_pointer)
      subject.artist.should be_nil
    end

    it "should be an artist if it exists" do
      subject.artist.should be_a Hallon::Artist
    end
  end

  describe "cover" do
    it "should be nil if there is no image" do
      Spotify.should_receive(:album_cover).and_return(null_pointer)
      subject.cover.should be_nil
    end

    it "should be an image if it exists" do
      FFI::MemoryPointer.new(:string, 20) do |ptr|
        ptr.write_string(mock_image_id)

        Spotify.should_receive(:album_cover).and_return(ptr)
        mock_session { subject.cover.id.should eq mock_image_hex }
      end
    end

    it "should be a link if requested" do
      Spotify.should_receive(:link_create_from_album_cover!).and_return(mock_image_link)
      subject.cover(false).to_str.should eq "spotify:image:3ad93423add99766e02d563605c6e76ed2b0e450"
    end
  end

  describe ".types" do
    specify { Hallon::Album.types.should_not be_empty }
  end
end
