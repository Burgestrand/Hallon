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

RSpec.configure do |config|
  config.before do
    Spotify.registry_add 'spotify:image:3ad93423add99766e02d563605c6e76ed2b0e400', mock_image
    Spotify.registry_add 'spotify:user:burgestrand:playlist:megaplaylist', mock_playlist_two
    Spotify.registry_add 'spotify:search:my+%C3%A5+utf8+%EF%A3%BF+query', mock_search
    Spotify.registry_add 'spotify:search:', mock_empty_search

    Spotify.registry_add 'spotify:albumbrowse:1xvnWMz2PNFf7mXOSRuLws', mock_albumbrowse
    Spotify.registry_add 'spotify:album:1xvnWMz2PNFf7mXOSRuLws', mock_album

    Spotify.registry_add 'spotify:albumbrowse:thisisanemptyalbumyoow', mock_empty_albumbrowse
    Spotify.registry_add 'spotify:album:thisisanemptyalbumyoow', mock_empty_album

    Spotify.registry_add 'spotify:artist:3bftcFwl4vqRNNORRsqm1G', mock_artist
    Spotify.registry_add 'spotify:artistbrowse:3bftcFwl4vqRNNORRsqm1G', mock_artistbrowse

    Spotify.registry_add 'spotify:artist:thisisanemptyartistyow', mock_empty_artist
    Spotify.registry_add 'spotify:artistbrowse:thisisanemptyartistyow', mock_empty_artistbrowse

    Spotify.registry_add 'spotify:container:burgestrand', mock_container

    Spotify.registry_add 'spotify:track:7N2Vc8u56VGA4KUrGbikC2', mock_track

    Spotify.registry_add 'spotify:user:burgestrand', mock_user
    Spotify.registry_add 'spotify:user:burgestrand:playlist:07AX9IY9Hqmj1RqltcG0fi', mock_playlist
    Spotify.registry_add 'spotify:user:burgestrand:starred', mock_playlist
  end
end
