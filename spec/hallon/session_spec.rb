# coding: utf-8
describe Hallon::Session do
  it { Hallon::Session.should_not respond_to :new }

  describe "#instance" do
    it "should require an application key" do
      expect { Hallon::Session.instance }.to raise_error(ArgumentError)
    end
  end

  describe "#new" do
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

    describe "#relation_type?" do
      it "should retrieve the relation between the current user and given user" do
        session.relation_type?(session.user).should eq :unknown
      end
    end
  end
end
