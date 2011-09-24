describe Hallon::Search do
  subject { search }
  let(:search) do
    mock_session do
      Spotify.should_receive(:search_create).and_return(mock_search)
      Hallon::Search.new("my query")
    end
  end

  describe ".new" do
    it "should have some sane defaults" do
      Spotify.should_receive(:search_create).with(session.pointer, "my query", 0, 25, 0, 25, 0, 25, anything, anything).and_return(mock_search)
      mock_session { Hallon::Search.new("my query") }
    end

    it "should allow you to customize the defaults" do
      Spotify.should_receive(:search_create).with(session.pointer, "my query", 1, 2, 3, 4, 5, 6, anything, anything).and_return(mock_search)
      my_params = {
        :tracks_offset  => 1,
        :tracks         => 2,
        :albums_offset  => 3,
        :albums         => 4,
        :artists_offset => 5,
        :artists        => 6
      }

      mock_session { Hallon::Search.new("my query", my_params) }
    end
  end

  describe ".genres" do
    subject { Hallon::Search.genres }

    it { should include :jazz }
    it { should be_a Array }
    it { should_not be_empty }
  end

  describe ".search" do
    subject do
      Spotify.should_receive(:radio_search_create).and_return(mock_search)

      mock_session do
        search = Hallon::Search.radio(1990..2010, :jazz, :punk)
      end
    end

    it "should simply ignore invalid genres" do
      mock_session do
        Spotify.should_receive(:radio_search_create).and_return(mock_search)
        expect { Hallon::Search.radio(1990..2010, :bogus, :hocum) }.to_not raise_error
      end
    end

    it { should be_loaded }
    its(:error) { should eq :ok }
    its('tracks.size') { should eq 2 }
    # ^ should be enough
  end

  it { should be_a Hallon::Observable }
  it { should be_loaded }
  its(:error) { should eq :ok }
  its(:query) { should eq "my query" }
  its(:did_you_mean) { should eq "another thing" }

  its('tracks.size')  { should eq 2 }
  its('tracks.to_a')  { should eq instantiate(Hallon::Track, mock_track, mock_track_two) }
  its('total_tracks') { should eq 1337 }

  its('albums.size')  { should eq 1 }
  its('albums.to_a')  { should eq instantiate(Hallon::Album, mock_album) }
  its('total_albums') { should eq 42 }

  its('artists.size')  { should eq 2 }
  its('artists.to_a')  { should eq instantiate(Hallon::Artist, mock_artist, mock_artist_two) }
  its('total_artists') { should eq 81104 }

  its(:to_link) { should eq Hallon::Link.new("spotify:search:#{search.query}") }
end
