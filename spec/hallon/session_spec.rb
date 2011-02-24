require 'ostruct' # https://github.com/rspec/rspec-core/issues/issue/264

describe Hallon::Session do
  # Hallon::Session#instance requires that a session have NOT been established,
  # thus its’ tests are declared in the spec_helper.rb
  
  context "once instantiated" do
    it_behaves_like "spotify objects" do
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
    
      describe "#merge_defaults" do
        define_method(:merge_defaults) do |*args|
          session.send(:merge_defaults, *args)
        end
        
        it "should return the defaults if no options given" do
          merge_defaults(nil).should be_a Hash # values not important
        end
      
        it "should allow given options to override defaults" do
          merge_defaults(:user_agent => "Cow")[:user_agent].should == "Cow"
        end
      end
    
      describe "#process_events" do
        it "should return the timeout" do
          session.process_events.should be_a Fixnum
        end
      end
    
      describe "#logout" do
        it "should check logged in status" do
          session.should_receive(:logged_in?).once
          expect { session.logout }.to_not raise_error
        end
      end
    end
  end
end