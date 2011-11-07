describe Hallon::Player do
  let(:player) { Hallon::Player.new(session) }
  let(:track) { Hallon::Track.new(mock_track) }

  describe ".bitrates" do
    it "should be a list of symbols in ascending order" do
      Hallon::Player.bitrates.should eq %w[96k 160k 320k].map(&:to_sym)
    end
  end

  describe "#bitrate=" do
    it "should not fail horribly given a correct bitrate" do
      player.bitrate = :'96k'
    end

    it "should fail horrible given a bad bitrate" do
      expect { player.bitrate = :'100k' }.to raise_error(ArgumentError)
    end
  end

  describe "#load" do
    it "should load the given track" do
      Spotify.should_receive(:session_player_load).with(session.pointer, track.pointer)
      player.load(track)
    end

    it "should raise an error if load was unsuccessful" do
      Spotify.should_receive(:session_player_load).and_return(:track_not_playable)
      expect { player.load(track) }.to raise_error(Hallon::Error, /TRACK_NOT_PLAYABLE/)
    end
  end

  describe "#stop" do
    it "should unload the currently loaded track" do
      Spotify.should_receive(:session_player_unload).with(session.pointer)
      player.stop
    end
  end

  describe "#prefetch" do
    it "should set up given track for prefetching" do
      Spotify.should_receive(:session_player_prefetch).with(session.pointer, track.pointer)
      player.prefetch(track)
    end
  end

  describe "#play" do
    it "should start playback of given track" do
      Spotify.should_receive(:session_player_play).with(session.pointer, true)
      player.play
    end

    it "should load and play given track if one was given" do
      Spotify.should_receive(:session_player_load).with(session.pointer, track.pointer)
      Spotify.should_receive(:session_player_play).with(session.pointer, true)
      player.play(track)
    end
  end

  describe "#pause" do
    it "should stop playback of given track" do
      Spotify.should_receive(:session_player_play).with(session.pointer, false)
      player.pause
    end
  end

  describe "#seek" do
    it "should set up the currently loaded track at given position" do
      Spotify.should_receive(:session_player_seek).with(session.pointer, 1000)
      player.seek(1)
    end
  end

  describe "#volume_normalization" do
    it "should be settable and gettable" do
      player.volume_normalization?.should be_false
      player.volume_normalization = true
      player.volume_normalization?.should be_true
    end
  end
end
