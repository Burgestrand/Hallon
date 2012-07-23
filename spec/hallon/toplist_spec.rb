# coding: utf-8

describe Hallon::Toplist do
  let(:toplist) do
    Spotify.mock_registry_add 'spotify:toplist:artists:everywhere', mock_toplistbrowse
    Hallon::Toplist.new(:artists)
  end

  let(:empty_toplist) do
    Spotify.mock_registry_add 'spotify:toplist:tracks:everywhere', mock_empty_toplistbrowse
    Hallon::Toplist.new(:tracks)
  end

  specify { toplist.should be_a Hallon::Loadable }
  specify { toplist.should be_a Hallon::Observable }

  describe ".new" do
    it "should fail given an invalid type" do
      expect { Hallon::Toplist.new(:invalid_type) }.to raise_error(ArgumentError, /invalid enum value/)
    end

    it "should pass the username given a string to libspotify" do
      Spotify.mock_registry_add 'spotify:toplist:user:Kim:tracks', mock_toplistbrowse
      Hallon::Toplist.new(:tracks, "Kim").should be_loaded
    end

    it "should pass the correct region to libspotify" do
      Spotify.mock_registry_add 'spotify:toplist:tracks:SE', mock_toplistbrowse
      Hallon::Toplist.new(:tracks, :se).should be_loaded
    end
  end

  describe "#loaded?" do
    it "returns true if the toplist is loaded" do
      toplist.should be_loaded
    end
  end

  describe "#status" do
    it "returns the toplist’s status" do
      toplist.status.should eq :ok
    end
  end

  describe "#type" do
    it "should be the same as the type given to .new" do
      toplist = Hallon::Toplist.new(:tracks, :se)
      toplist.type.should eq :tracks
    end
  end

  describe "#results" do
    it "should return an enumerator of the correct type" do
      toplist.should_receive(:type).and_return(:artists)
      toplist.results.to_a.should eq instantiate(Hallon::Artist, mock_artist, mock_artist_two)
    end

    it "should return an enumerator of the correct type" do
      toplist.should_receive(:type).and_return(:albums)
      toplist.results.to_a.should eq instantiate(Hallon::Album, mock_album)
    end

    it "should return an enumerator of the correct type" do
      toplist.should_receive(:type).and_return(:tracks)
      toplist.results.to_a.should eq instantiate(Hallon::Track, mock_track, mock_track_two)
    end

    it "returns an empty enumerator when there are no results" do
      empty_toplist.results.should be_empty
    end
  end

  describe "#request_duration" do
    it "should return the request duration in seconds" do
      toplist.request_duration.should eq 2.751
    end

    it "should be zero if the request was fetched from local cache" do
      empty_toplist.request_duration.should eq 0
    end
  end
end
