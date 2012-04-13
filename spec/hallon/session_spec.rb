# coding: utf-8
describe Hallon::Session do
  it { Hallon::Session.should_not respond_to :new }

  describe ".initialize and .instance" do
    before { Hallon.instance_eval { @__instance = nil } }
    after  { Hallon.instance_eval { @__instance = nil } }

    it "should fail if calling instance before initialize" do
      expect { Hallon.instance }.to raise_error
    end

    it "should fail if calling initialize twice" do
      expect {
        Hallon.initialize
        Hallon.initialize
      }.to raise_error
    end

    it "should succeed if everything is right" do
      expect { Hallon::Session.initialize('appkey_good') }.to_not raise_error
    end
  end

  describe ".new" do
    it "should require an application key" do
      expect { Hallon::Session.send(:new) }.to raise_error(ArgumentError)
    end

    it "should fail on an invalid application key" do
      expect { create_session(false) }.to raise_error(Hallon::Error, /BAD_APPLICATION_KEY/)
    end

    it "should fail on a small user-agent of multibyte chars (> 255 characters)" do
      expect { create_session(true, :user_agent => 'ö' * 128) }.to raise_error(ArgumentError)
    end

    it "should fail on a huge user agent (> 255 characters)" do
      expect { create_session(true, :user_agent => 'a' * 256) }.to raise_error(ArgumentError)
    end
  end

  describe "options" do
    subject { session.options }
    its([:user_agent]) { should == options[:user_agent] }
    its([:settings_path]) { should == options[:settings_path] }
    its([:cache_path]) { should == options[:cache_path] }

    its([:load_playlists]) { should == true }
    its([:compress_playlists]) { should == true }
    its([:cache_playlist_metadata]) { should == true }
  end

  describe "#container" do
    it "should return the sessions’ playlist container" do
      session.login 'burgestrand', 'pass'
      session.container.should eq Hallon::PlaylistContainer.new(mock_container)
    end

    it "should return nil if not logged in" do
      session.container.should be_nil
    end
  end

  describe "#process_events" do
    it "should return the timeout" do
      session.process_events.should be_a Fixnum
    end
  end

  describe "#process_events_on" do
    it "should not call given block on :notify_main_thread implicitly" do
      notified = false

      session.should_receive(:process_events).twice.and_return do
        unless notified
          session.class.send(:notify_main_thread_callback, session.pointer)
          notified = true
        else
          session.class.send(:logged_in_callback, session.pointer, :ok)
        end

        0
      end

      session.process_events_on(:logged_in) { |e| e == :ok }.should be_true
    end

    it "should time out if waiting for events too long" do
      session.should_receive(:process_events).once.and_return(1) # and do nothing
      session.wait_for(:logged_in) { |x| x }.should eq :timeout
    end

    it "should call the given block once before waiting" do
      session.should_not_receive(:process_events)
      session.process_events_on { true }
    end
  end

  describe "#relogin" do
    it "should raise if no credentials have been saved" do
      expect { session.relogin }.to raise_error(Hallon::Error)
    end

    it "should not raise if credentials have been saved" do
      session.login 'Kim', 'pass', true
      session.logout
      expect { session.relogin }.to_not raise_error
      session.should be_logged_in
    end
  end

  describe "#remembered_user" do
    it "should be nil if no username is stored in libspotify" do
      session.remembered_user.should eq nil
    end

    it "should retrieve the remembered username if stored" do
      session.login 'Kim', 'pass', true
      session.remembered_user.should eq 'Kim'
    end
  end

  describe "#forget_me!" do
    it "should forget the currently stored user credentials" do
      session.login 'Kim', 'pass', true
      session.remembered_user.should eq 'Kim'
      session.forget_me!
      session.remembered_user.should eq nil
    end
  end

  describe "#login" do
    it "should raise an error when given empty credentials" do
      expect { session.login '', 'pass' }.to raise_error(ArgumentError)
      expect { session.login 'Kim', '' }.to raise_error(ArgumentError)
    end
  end

  describe "#logout" do
    it "should check logged in status" do
      session.should_receive(:logged_in?).once.and_return(false)
      expect { session.logout }.to_not raise_error
    end
  end

  describe "#user" do
    it "should return the logged in user" do
      session.login 'Kim', 'pass'
      session.user.name.should eq 'Kim'
    end

    it "should return nil if not logged in" do
      session.user.should be_nil
    end
  end

  describe "#country" do
    it "should retrieve the current sessions’ country as a string" do
      session.country.should eq 'SE'
    end
  end

  describe "#star and #unstar" do
    it "should be able to star and unstar tracks" do
      # for track#starred?
      Hallon::Session.should_receive(:instance).exactly(6).times.and_return(session)

      tracks = [mock_track, mock_track_two]
      tracks.map! { |x| Hallon::Track.new(x) }
      tracks.all?(&:starred?).should be_true # starred by default

      session.unstar(*tracks)
      tracks.none?(&:starred?).should be_true

      session.star(tracks[0])
      tracks[0].should be_starred
      tracks[1].should_not be_starred
    end
  end

  describe "#cache_size" do
    it "should default to 0" do
      session.cache_size.should eq 0
    end

    it "should be settable" do
      session.cache_size = 10
      session.cache_size.should eq 10
    end
  end

  describe ".connection_types" do
    subject { Hallon::Session.connection_types }

    it { should be_an Array }
    it { should_not be_empty }
    it { should include :wifi }
  end

  describe "#connection_type=" do
    it "should fail given an invalid connection type" do
      expect { session.connection_type = :bogus }.to raise_error(ArgumentError)
    end

    it "should succeed given a correct connection type" do
      expect { session.connection_type = :wifi }.to_not raise_error
    end
  end

  describe ".connection_types" do
    subject { Hallon::Session.connection_rules }

    it { should be_an Array }
    it { should_not be_empty }
    it { should include :network }
  end

  describe "#connection_rules=" do
    it "should fail given an invalid rule" do
      expect { session.connection_rules = :lawly }.to raise_error
    end

    it "should succeed given correct connection thingy" do
      expect { session.connection_rules = :network, :allow_sync_over_mobile }.to_not raise_error
    end

    it "should combine given rules and feed to libspotify" do
      Spotify.should_receive(:session_set_connection_rules).with(session.pointer, 5)
      session.connection_rules = :network, :allow_sync_over_mobile
    end
  end

  describe "offline settings readers" do
    subject { mock_session_object }

    its(:offline_time_left) { should eq 60 * 60 * 24 * 30 } # a month!
    its(:offline_sync_status) { should eq mock_offline_sync_status_hash }
    its(:offline_playlists_count) { should eq 7 }
    its(:offline_tracks_to_sync) { should eq 3 }

    specify "offline_sync_status when given false as return from libspotify" do
      Spotify.should_receive(:offline_sync_get_status).and_return(false)
      subject.offline_sync_status.should eq nil
    end
  end

  describe "#offline_bitrate=" do
    it "should not resync unless explicitly told so" do
      Spotify.should_receive(:session_preferred_offline_bitrate).with(session.pointer, :'96k', false)
      session.offline_bitrate = :'96k'
    end

    it "should resync if asked to" do
      Spotify.should_receive(:session_preferred_offline_bitrate).with(session.pointer, :'96k', true)
      session.offline_bitrate = :'96k', true
    end

    it "should fail given an invalid value" do
      expect { session.offline_bitrate = :hocum }.to raise_error(ArgumentError)
    end

    it "should succeed given a proper value" do
      expect { session.offline_bitrate = :'96k' }.to_not raise_error
    end
  end


  describe "#starred" do
    let(:starred) { Hallon::Playlist.new("spotify:user:burgestrand:starred") }

    it "should return the sessions (current users) starred playlist" do
      session.login 'burgestrand', 'pass'

      session.should be_logged_in
      session.starred.should eq starred
    end

    it "should return nil if not logged in" do
      session.should_not be_logged_in
      session.starred.should be_nil
    end
  end

  describe "#inbox" do
    let(:inbox) { Hallon::Playlist.new(mock_playlist) }
    let(:session) { mock_session_object }

    it "should return the sessions inbox" do
      session.login 'burgestrand', 'pass'

      session.should be_logged_in
      session.inbox.should eq inbox
    end

    it "should return nil if not logged in" do
      session.should_not be_logged_in
      session.inbox.should be_nil
    end
  end
end
