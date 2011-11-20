describe Hallon::Toplist do
  let(:toplist) do
    Spotify.registry_add 'spotify:toplist:artists:everywhere', mock_toplistbrowse
    mock_session { Hallon::Toplist.new(:artists) }
  end

  subject { toplist }

  it { should be_a Hallon::Observable }
  it { should be_loaded }
  its(:status) { should eq :ok }

  its('artists.size') { should eq 2 }
  its('artists.to_a') { should eq instantiate(Hallon::Artist, mock_artist, mock_artist_two) }

  its('albums.size') { should eq 1 }
  its('albums.to_a') { should eq instantiate(Hallon::Album, mock_album) }

  its('tracks.size') { should eq 2 }
  its('tracks.to_a') { should eq instantiate(Hallon::Track, mock_track, mock_track_two) }

  describe "#request_duration" do
    it "should return the request duration in seconds" do
      toplist.request_duration.should eq 2.751
    end

    it "should be nil if the request was fetched from local cache" do
      Spotify.should_receive(:toplistbrowse_backend_request_duration).and_return(-1)
      toplist.request_duration.should be_nil
    end
  end

  describe ".new" do
    it "should fail given an invalid type" do
      expect { mock_session { Hallon::Toplist.new(:invalid_type) } }.to raise_error(ArgumentError, /invalid enum value/)
    end

    it "should pass the username given a string to libspotify" do
      Spotify.registry_add 'spotify:toplist:user:Kim', mock_toplistbrowse
      mock_session { Hallon::Toplist.new(:tracks, "Kim").should be_loaded }
    end

    it "should pass the correct region to libspotify" do
      Spotify.registry_add 'spotify:toplist:tracks:SE', mock_toplistbrowse
      mock_session { Hallon::Toplist.new(:tracks, :se).should be_loaded }
    end
  end
end
