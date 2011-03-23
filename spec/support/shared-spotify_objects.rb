# All Spotify objects require a valid session. This provides it for them.
shared_examples_for "spotify objects" do
  let(:options) { {:user_agent => "Hallon (rspec)", :settings_path => "tmp", :cache_path => "tmp/cache"} }
  let(:session) { Hallon::Session.instance(Hallon::APPKEY, options) }
  before(:all) { session }
end