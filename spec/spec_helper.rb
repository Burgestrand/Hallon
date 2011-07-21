# coding: utf-8
require 'mockspotify'
require 'hallon'

# Bail on failure
Thread.abort_on_exception = true

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true

  def fixture_image_path
    File.expand_path('../fixtures/pink_cover.jpg', __FILE__)
  end

  def create_session(valid_appkey = true, options = options)
    appkey = valid_appkey ? 'appkey_good' : 'appkey_bad'
    Hallon::Session.send(:new, appkey, options)
  end
end

RSpec::Core::ExampleGroup.instance_eval do
  let(:options) do
    {
      :user_agent => "Hallon (rspec)",
      :settings_path => "tmp",
      :cache_path => ""
    }
  end

  let(:session) { create_session }
end

# Requires supporting files in ./support/ and ./fixtures/
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
Dir["#{File.dirname(__FILE__)}/fixtures/**/*.rb"].each {|f| require f}
