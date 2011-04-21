shared_examples_for "pre-initialized Session" do
  let(:options) { {:user_agent => "Hallon (rspec)", :settings_path => "tmp", :cache_path => "tmp/cache"} }
  let(:session) { Hallon::Session.instance(Hallon::APPKEY, options) }
  before(:all) { @session = session }
end