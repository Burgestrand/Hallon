# coding: utf-8
describe Hallon::Track do
  let(:track) do
    Hallon::Track.new(mock_tracks[:default])
  end

  let(:empty_track) do
    Hallon::Track.new(mock_tracks[:empty])
  end

  let(:autolinked_track) do
    Hallon::Track.new(mock_tracks[:linked])
  end

  specify { track.should be_a Hallon::Loadable }

  it_should_behave_like "a Linkable object" do
    let(:spotify_uri) { "spotify:track:7N2Vc8u56VGA4KUrGbikC2#01:00" }
  end

  describe "#loaded?" do
    it "returns true if the track is loaded" do
      track.should be_loaded
    end
  end

  describe "#name" do
    it "returns the track’s name" do
      track.name.should eq "They"
    end

    it "returns an empty string if the track’s name is unavailable" do
      empty_track.name.should be_empty
    end
  end

  describe "#disc" do
    it "returns the track’s disc number in it’s album" do
      track.disc.should eq 2
    end
  end

  describe "#index" do
    it "returns the track’s position on the disc" do
      track.index.should eq 7
    end
  end

  describe "#status" do
    it "returns the track’s status" do
      track.status.should eq :ok
    end
  end

  describe "#duration" do
    it "returns track’s duration" do
      track.duration.should eq 123.456
    end
  end

  describe "#popularity" do
    it "returns the track’s popularity" do
      track.popularity.should eq 42
    end
  end

  describe "#playable_track" do
    it "returns the autolinked track" do
      linked = autolinked_track.playable_track
      linked.should_not eq autolinked_track
      linked.should eq track
    end

    it "returns itself if the track is not autolinked" do
      track.playable_track.should eq track
    end
  end

  describe "#available?" do
    it "returns true if the track is available for playback" do
      track.should be_available
    end
  end

  describe "#local?" do
    it "returns true if the track is a local track" do
      track.should_not be_local
    end
  end

  describe "#autolinked?" do
    it "returns true if the track is autolinked to another for playback" do
      track.should be_autolinked
    end
  end

  describe "#availability" do
    it "returns the track’s availability" do
      track.availability.should eq :available
    end
  end

  describe "#album" do
    it "returns the track’s album" do
      track.album.should eq Hallon::Album.new(mock_album)
    end

    it "returns nil if the track’s not loaded" do
      empty_track.album.should be_nil
    end
  end

  describe "#artist" do
    it "returns the track’s artist" do
      track.artist.should eq Hallon::Artist.new(mock_artist)
    end

    it "returns nil if the track’s not loaded" do
      empty_track.artist.should be_nil
    end
  end

  describe "#artists" do
    it "returns an enumerator of the track’s artists" do
      track.artists.to_a.should eq instantiate(Hallon::Artist, mock_artist, mock_artist_two)
    end

    it "returns an empty enumerator if the track has no artists" do
      empty_track.artists.should be_empty
    end
  end

  describe "#starred=" do
    it "should delegate to session to unstar" do
      session.should_receive(:unstar).with(track)
      track.starred = false
    end

    it "should delegate to session to star" do
      session.should_receive(:star).with(track)
      track.starred = true
    end

    it "should change starred status of track" do
      track.should be_starred
      track.starred = false
      track.should_not be_starred
    end
  end

  describe "#to_link" do
    it "should pass the current offset by default" do
      track.should_receive(:offset).and_return(10)
      track.to_link.to_str.should match(/#00:10/)
    end

    it "should accept offset as parameter" do
      track.should_not_receive(:offset)
      track.to_link(1337).to_str.should match(/#22:17/)
    end
  end

  describe "#placeholder?" do
    let(:yes) { Hallon::Track.new(mock_track_two) }

    it "should return the placeholder status of the track" do
      yes.should be_placeholder
      track.should_not be_placeholder
    end
  end

  describe "#unwrap" do
    let(:track) { Hallon::Track.new(mock_track_two) }
    let(:playlist) { Spotify.link_create_from_string!('spotify:user:burgestrand:playlist:07AX9IY9Hqmj1RqltcG0fi') }
    let(:artist)   { Spotify.link_create_from_string!('spotify:artist:3bftcFwl4vqRNNORRsqm1G') }
    let(:album)    { Spotify.link_create_from_string!('spotify:album:1xvnWMz2PNFf7mXOSRuLws') }

    it "does nothing if the track is not a placeholder" do
      track.stub(:placeholder? => false)
      track.unwrap.should eq track
    end

    it "should unwrap a playlist placeholder into a playlist" do
      Spotify.should_receive(:link_create_from_track!).and_return(playlist)
      track.unwrap.should eq Hallon::Playlist.new(playlist)
    end

    it "should unwrap an album placeholder into an album" do
      Spotify.should_receive(:link_create_from_track!).and_return(album)
      track.unwrap.should eq Hallon::Album.new(album)
    end

    it "should unwrap an artist placeholder into an artist" do
      Spotify.should_receive(:link_create_from_track!).and_return(artist)
      track.unwrap.should eq Hallon::Artist.new(artist)
    end
  end

  describe "#offline_status" do
    it "should return the tracks’ offline status" do
      track.offline_status.should eq :done
    end
  end

  describe "#offset" do
    let(:without_offset) { 'spotify:track:7N2Vc8u56VGA4KUrGbikC2' }
    let(:with_offset)    { without_offset + '#1:00' }

    specify "with offset" do
      Hallon::Track.new(with_offset).offset.should eq 60
    end

    specify "without offset" do
      Hallon::Track.new(without_offset).offset.should eq 0
    end

    specify "when instantiated from a pointer" do
      Hallon::Track.new(mock_track).offset.should eq 0
    end
  end

  describe "a local track" do
    let(:local) do
      Hallon::Track.local "Nissy", "Emmy", "Coolio", 100
    end

    describe "#name" do
      it "returns the track’s name" do
        local.name.should eq "Nissy"
      end
    end

    describe "#album" do
      it "returns the track’s album" do
        local.album.name.should eq "Coolio"
      end
    end

    describe "#artist" do
      it "returns the track’s artist" do
        local.artist.name.should eq "Emmy"
      end
    end

    describe "#duration" do
      it "returns the track’s duration" do
        local.duration.should eq 0.1
      end
    end

    describe "#local?" do
      it "returns true for local tracks" do
        local.should be_local
      end
    end
  end
end
