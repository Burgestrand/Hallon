# coding: utf-8
require 'bundler/setup'

begin
  require 'cover_me'
rescue LoadError
  # ignore, only for development, it’s in the Gemfile
end

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

  def instantiate(klass, *pointers)
    pointers.map { |x| klass.new(x) }
  end

  def mock_session
    Hallon::Session.should_receive(:instance).at_least(1).times.and_return(session)
    yield
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
