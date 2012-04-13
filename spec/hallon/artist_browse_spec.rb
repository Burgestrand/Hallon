# coding: utf-8

describe Hallon::ArtistBrowse do
  let(:browse) do
    artist = Hallon::Artist.new(mock_artists[:default])
    Hallon::ArtistBrowse.new(artist)
  end

  let(:empty_browse) do
    artist = Hallon::Artist.new(mock_artists[:empty])
    Hallon::ArtistBrowse.new(artist)
  end

  specify { browse.should be_a Hallon::Loadable }

  describe ".new" do
    it "should raise an error if the browse request failed" do
      Spotify.should_receive(:artistbrowse_create).and_return(null_pointer)
      expect { Hallon::ArtistBrowse.new(mock_artist) }.to raise_error(FFI::NullPointerError)
    end

    it "should raise an error given a non-album spotify pointer" do
      expect { Hallon::ArtistBrowse.new(mock_album) }.to raise_error(TypeError)
    end
  end

  describe '.types' do
    subject { Hallon::ArtistBrowse.types }

    it { should be_an Array }
    it { should include :full }
  end

  describe "#loaded?" do
    it "is true when the artist browser is loaded" do
      browse.should be_loaded
    end
  end

  describe "#status" do
    it "returns the artist browser’s status" do
      browse.status.should eq :ok
    end
  end

  describe "#biography" do
    it "returns the artist’s biography" do
      browse.biography.should eq 'grew up in DA BLOCK'
    end

    it "returns an empty string when the artist browser is not loaded" do
      empty_browse.biography.should be_empty
    end
  end

  describe "#artist" do
    it "returns the artist" do
      browse.artist.should eq Hallon::Artist.new(mock_artists[:default])
    end

    it "returns nil if the artist browser is not loaded" do
      empty_browse.artist.should be_nil
    end
  end

  describe "#portraits" do
    it "returns an enumerator of the artist’s portraits" do
      browse.portraits.to_a.should eq instantiate(Hallon::Image, mock_image_id, mock_image_id)
    end

    it "returns an empty enumerator when the artist browser is not loaded" do
      empty_browse.portraits.size.should eq 0
    end
  end

  describe "#portrait_links" do
    it "returns an enumerator of the artist’s portrait links" do
      browse.portrait_links.to_a.should eq instantiate(Hallon::Link, mock_image_link, mock_image_link)
    end

    it "returns an empty enumerator when the artist browser is not loaded" do
      empty_browse.portrait_links.size.should eq 0
    end
  end

  describe "#tracks" do
    it "returns an enumerator of the artist’s tracks" do
      browse.tracks.to_a.should eq instantiate(Hallon::Track, mock_track, mock_track_two)
    end

    it "returns an empty enumerator when the artist browser is not loaded" do
      empty_browse.tracks.size.should eq 0
    end
  end

  describe "#albums" do
    it "returns an enumerator of the artist’s albums" do
      browse.albums.to_a.should eq instantiate(Hallon::Album, mock_album)
    end

    it "returns an empty enumerator when the artist browser is not loaded" do
      empty_browse.albums.size.should eq 0
    end
  end

  describe "#similar_artists" do
    it "returns an enumerator of the artist’s albums" do
      browse.similar_artists.to_a.should eq instantiate(Hallon::Artist, mock_artist, mock_artist_two)
    end

    it "returns an empty enumerator when the artist browser is not loaded" do
      empty_browse.similar_artists.size.should eq 0
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
