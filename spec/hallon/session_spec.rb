require 'monitor'

describe Hallon::Session do
  # Hallon::Session#instance requires that a session have NOT been established,
  # thus its’ tests are declared in the spec_helper.rb
  context "once instantiated" do
    has_requirement "pre-initialized Session" do
      describe "appkey" do
        it "should == Hallon::APPKEY" do session.appkey.should == Hallon::APPKEY end
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
      
      describe "#login" do
        it "should log in to Spotify" do
          mutex  = Monitor.new
          notify = mutex.new_cond
          login_error = nil
          
          mutex.synchronize do
            session.on(:notify_main_thread) do
              mutex.synchronize { notify.signal }
            end
            
            session.on(:logged_in) do |error|
              mutex.synchronize do
                login_error = error
                notify.signal
              end
            end
            
            session.login ENV['HALLON_USERNAME'], ENV['HALLON_PASSWORD']
            session.process_events
            
            notify.wait_until do
              session.process_events
              session.logged_in?
            end
          end
          
          session.logged_in?.should be true
          login_error.should be :ok
        end
      end
    end
  end
end