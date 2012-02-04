# coding: utf-8
describe Hallon::Player do
  let(:player) { Hallon::Player.new(session, AudioDriverMock) }
  let(:track)  { Hallon::Track.new(mock_track) }
  let(:driver) { player.instance_variable_get('@driver') }
  let(:queue)  { player.instance_variable_get('@queue') } # black box? WHAT?

  describe "events" do
    %w(end_of_track streaming_error play_token_lost).each do |e|
      it "should support listening for #{e}" do
        expect { player.on(e) {} }.to_not raise_error
      end
    end
  end

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

    it "should try to instantiate the track if it’s not a track" do
      Spotify.should_receive(:session_player_load).with(session.pointer, track.pointer)
      player.load(track.to_str)
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
      Spotify.should_receive(:session_player_play).with(session.pointer, true)
      player.should_receive(:load).with(track)
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

  context "playing audio" do
    before { session.class.send(:public, :trigger) }

    it "should correctly report the status to libspotify" do
      queue.should_receive(:size).and_return(7)
      driver.should_receive(:drops).and_return(19)
      session.trigger(:get_audio_buffer_stats).should eq [7, 19]
    end

    it "should assume no drops in audio if driver does not support checking" do
      driver.should_receive(:respond_to?).with(:drops).and_return(false)
      driver.should_not_receive(:drops)
      session.trigger(:get_audio_buffer_stats).should eq [0, 0]
    end

    it "should tell the driver to start playback when commanded so by libspotify" do
      driver.should_receive(:play)
      session.trigger(:start_playback)
    end

    it "should tell the driver to stop playback when commanded so by libspotify" do
      driver.should_receive(:pause)
      session.trigger(:stop_playback)
    end

    it "should tell the driver to pause when pause is requested" do
      driver.should_receive(:pause)
      player.pause
    end

    it "should tell the driver to stop when stop is requested" do
      queue.should_receive(:clear)
      driver.should_receive(:stop)
      player.stop
    end

    it "should not set the format on music delivery if it’s the same" do
      queue.should_not_receive(:format=)
      session.trigger(:music_delivery, queue.format, [1, 2, 3])
    end

    it "should set the format on music delivery if format changes" do
      queue.should_receive(:format=).with(:new_format)
      session.trigger(:music_delivery, :new_format, [1, 2, 3])
    end

    # why? it says so in the docs!
    it "should clear the audio queue when receiving 0 audio frames" do
      queue.should_receive(:clear)
      session.trigger(:music_delivery, driver.format, [])
    end

    context "the output streaming" do
      it "should feed music to the output stream if the format stays the same" do
        Thread.stub(:start).and_return{ |*args, block| block[*args] }

        player # create the Player
        session.trigger(:music_delivery, queue.format, [1, 2, 3])

        # it should block while player is stopped
        begin
          player.status.should be :stopped
          Timeout::timeout(0.1) { driver.stream.call and "call was not blocking" }
        rescue
          :timeout
        end.should eq :timeout

        session.trigger(:start_playback)
        player.status.should be :playing
        driver.stream.call(1).should eq [1]
        driver.stream.call(nil).should eq [2, 3]
      end

      it "should set the driver format and return no audio if audio format has changed" do
        Thread.stub(:start).and_return{ |*args, block| block[*args] }

        player # create the Player
        session.trigger(:start_playback)
        session.trigger(:music_delivery, :new_format, [1, 2, 3])

        driver.should_receive(:format=).with(:new_format)
        driver.stream.call.should be_nil

        # driver.should_not_receive(:format)
        driver.should_receive(:format).and_return(:new_format)
        driver.stream.call.should eq [1, 2, 3]
      end

      it "should set the format on initialization" do
        Thread.stub(:start).and_return{ |*args, block| block[*args] }
        AudioDriverMock.any_instance.should_receive(:format=)
        Hallon::AudioQueue.any_instance.should_receive(:format=)
        player
      end
    end
  end
end
