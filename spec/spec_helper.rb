# coding: utf-8

require 'bundler'
Bundler.setup

begin
  require 'cover_me'
rescue LoadError
  # ignore, only for development, it’s in the Gemfile
end

require 'mockspotify'
require 'hallon'

# Bail on failure
Thread.abort_on_exception = true

# We don’t do long running tests.
# Actually, some tests might deadlock, so we guard against
# them doing that. It’s annoying.
class SlowTestError < StandardError
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.before do
    Hallon::Session.stub(:instance?).and_return(true)
    Hallon::Session.stub(:instance).and_return(session)
  end

  config.after do
    Spotify.registry_clean
  end

  def fixture_image_path
    File.expand_path('../fixtures/pink_cover.jpg', __FILE__)
  end

  def create_session(valid_appkey = true, options = options)
    appkey = valid_appkey ? 'appkey_good' : 'appkey_bad'
    Hallon::Session.send(:new, appkey, options)
  end

  def instantiate(klass, *pointers)
    pointers.map { |x| klass.new(*x) }
  end

  def pointer_array_with(*args)
    ary = FFI::MemoryPointer.new(:pointer, args.size)
    ary.write_array_of_pointer args
    def ary.length
      size / type_size
    end

    ary
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
