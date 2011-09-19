# coding: utf-8
describe Hallon::Album do
  subject { Hallon::Album.new(mock_album) }

  its(:name) { should eq "Finally Woken" }
  its(:year) { should be 2004 }
  its(:type) { should be :single }
  its(:browse) { should eq Hallon::AlbumBrowse.new(mock_album) }

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
    before { Hallon::Session.should_receive(:instance).and_return(session) }

    it "should be nil if there is no image" do
      Spotify.should_receive(:album_cover).and_return(null_pointer)
      subject.cover.should be_nil
    end

    it "should be an image if it exists" do
      FFI::MemoryPointer.new(:string, 20) do |ptr|
        ptr.write_string(mock_image_id)

        Spotify.should_receive(:album_cover).and_return(ptr)
        subject.cover.id.should eq mock_image_hex
      end
    end
  end

  describe ".types" do
    specify { Hallon::Album.types.should_not be_empty }
  end
end
