describe Hallon::Session do
  has_requirement "existing session" do
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

    describe "#status" do
      it { session.status.should equal :logged_out }
    end

    describe "#logout" do
      it "should check logged in status" do
        session.should_receive(:logged_in?).once.and_return(false)
        expect { session.logout }.to_not raise_error
      end
    end

    has_requirement "logged in" do
      it "should be logged in" do
        @session.should be_logged_in
      end
    end
  end
end
