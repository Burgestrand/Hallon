describe Hallon::Session do
  include_context "initialized session"

  describe "appkey" do
    it "should == Hallon::APPKEY" do
      session.appkey.should == Hallon::APPKEY
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

      session.process_events_on(:bogus) { |e| e.inspect }.should eq ":bogus"
    end

    it "should time out if waiting for events too long" do
      session.should_receive(:process_events).once.and_return { session.trigger(:whatever) }
      session.process_events_on(:whatever) { |e| e.inspect }.should eq "nil"
    end
  end

  describe "#logout" do
    it "should check logged in status" do
      session.should_receive(:logged_in?).once.and_return(false)
      expect { session.logout }.to_not raise_error
    end
  end

  context "when logged in", :logged_in => true do
    it "should be logged in" do
      session.should be_logged_in
    end
  end
end
