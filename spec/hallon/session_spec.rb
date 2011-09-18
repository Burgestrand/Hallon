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
          session.trigger(:notify_main_thread, :notify)
          notified = true
        else
          session.trigger(:bogus, :bogus)
        end
      end

      session.process_events_on(:bogus) { |e| e == :bogus }.should be_true
    end

    it "should time out if waiting for events too long" do
      session.should_receive(:process_events).once # and do nothing
      session.wait_for(:ever) { |x| x }.should eq :timeout
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
    before { session.login 'Kim', 'pass', true }

    it "should forget the currently stored user credentials" do
      session.remembered_user.should eq 'Kim'
      session.forget_me!
      session.remembered_user.should eq nil
    end
  end

  describe "#logout" do
    it "should check logged in status" do
      session.should_receive(:logged_in?).once.and_return(false)
      expect { session.logout }.to_not raise_error
    end
  end

  describe "#country" do
    it "should retrieve the current sessions’ country as a string" do
      session.country.should eq 'SE'
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

  context "when logged in", :logged_in => true do
    it "should be logged in" do
      session.should be_logged_in
    end

    describe "#relation_type?" do
      it "should retrieve the relation between the current user and given user" do
        session.relation_type?(session.user).should eq :none
      end
    end
  end
end
