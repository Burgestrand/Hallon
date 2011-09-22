describe Hallon::Toplist do
  subject do
    expect_session_instance(1)
    Spotify.should_receive(:toplistbrowse_create).and_return(mock_toplistbrowse)
    Hallon::Toplist.new(:artists)
  end

  it { should be_a Hallon::Observable }
  it { should be_loaded }
  its(:error) { should eq :ok }

  its('artists.size') { should eq 2 }
  its('artists.to_a') { should eq instantiate(Hallon::Artist, mock_artist, mock_artist_two) }

  its('albums.size') { should eq 1 }
  its('albums.to_a') { should eq instantiate(Hallon::Album, mock_album) }

  its('tracks.size') { should eq 2 }
  its('tracks.to_a') { should eq instantiate(Hallon::Track, mock_track, mock_track_two) }

  describe ".new" do
    before { expect_session_instance(1) }

    it "should fail given an invalid type" do
      expect { Hallon::Toplist.new(:invalid_type) }.to raise_error(ArgumentError, /invalid enum value/)
    end

    it "should pass the username given a string to libspotify" do
      Spotify.should_receive(:toplistbrowse_create).with(anything, anything, :user, "Kim", anything, nil).and_return(null_pointer)
      Hallon::Toplist.new(:artists, "Kim")
    end

    it "should pass the correct region to libspotify" do
      sweden = 21317
      Spotify.should_receive(:toplistbrowse_create).with(anything, anything, sweden, anything, anything, nil).and_return(null_pointer)
      Hallon::Toplist.new(:artists, :se)
    end
  end
end
