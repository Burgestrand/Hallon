# coding: utf-8
describe Hallon::AlbumBrowse do
  let(:browse) do
    album = Hallon::Album.new(mock_albums[:default])
    Hallon::AlbumBrowse.new(album)
  end

  let(:empty_browse) do
    album = Hallon::Album.new(mock_albums[:empty])
    Hallon::AlbumBrowse.new(album)
  end

  specify { browse.should be_a Hallon::Loadable }

  describe ".new" do
    it "should raise an error if the browse request failed" do
      Spotify.should_receive(:albumbrowse_create).and_return(null_pointer)
      expect { Hallon::AlbumBrowse.new(mock_album) }.to raise_error(FFI::NullPointerError)
    end

    it "should raise an error given a non-album spotify pointer" do
      expect { Hallon::AlbumBrowse.new(mock_artist) }.to raise_error(TypeError)
    end
  end

  describe "#loaded?" do
    it "is true when the album browser is loaded" do
      browse.should be_loaded
    end
  end

  describe "#status" do
    it "returns the album status" do
      browse.status.should eq :ok
    end
  end

  describe "#album" do
    it "returns the album" do
      browse.album.should eq Hallon::Album.new(mock_albums[:default])
    end
  end

  describe "#artist" do
    it "returns the album’s artist" do
      browse.artist.should eq Hallon::Artist.new(mock_artists[:default])
    end

    it "returns nil if the album browser is not loaded" do
      empty_browse.artist.should be_nil
    end
  end

  describe "#review" do
    it "returns the album’s review" do
      browse.review.should eq "This album is AWESOME"
    end

    it "returns an empty string if the album browser is not loaded" do
      empty_browse.review.should be_empty
    end
  end

  describe "#copyrights" do
    it "returns an enumerator of the album’s copyright texts" do
      browse.copyrights.to_a.should eq %w[Kim Elin]
    end

    it "returns an empty enumerator when the album browser is not loaded" do
      empty_browse.copyrights.size.should eq 0
    end
  end

  describe "#tracks" do
    it "returns an enumerator of the album’s tracks" do
      browse.tracks.to_a.should eq instantiate(Hallon::Track, mock_track, mock_track_two) 
    end

    it "returns an empty enumerator if the album browser is not loaded" do
      empty_browse.tracks.size.should eq 0
    end
  end

  describe "#request_duration" do
    it "should return the request duration in seconds" do
      browse.request_duration.should eq 2.751
    end

    it "should be zero if the request was fetched from local cache" do
      empty_browse.request_duration.should eq 0
    end
  end
end
