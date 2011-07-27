# coding: utf-8
describe Hallon::Album do
  subject { Hallon::Album.new(mock_album) }

  its(:name) { should eq "Finally Woken" }
  its(:year) { should be 2004 }
  its(:type) { should be :single }

  it { should be_available }
  it { should be_loaded }

  describe "artist" do
    it "should be nil if there is no artist" do
      Spotify.should_receive(:album_artist).and_return(null_pointer)
      subject.artist.should be_nil
    end

    it "should be an artist if it exists"
  end

  describe "cover" do
    it "should be nil if there is no image" do
      Spotify.should_receive(:album_cover).and_return(null_pointer)
      subject.cover.should be_nil
    end

    it "should be an image if it exists"
  end

  describe ".types" do
    it "should not be an empty hash" do
      Hallon::Album.types.should_not be_empty
    end
  end
end
