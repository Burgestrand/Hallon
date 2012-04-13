# coding: utf-8
require 'time'

RSpec::Core::ExampleGroup.instance_eval do
  let(:mock_user)   { Spotify.mock_user!("burgestrand", "Burgestrand", true) }
  let(:mock_user_raw) { FFI::Pointer.new(mock_user.address) }

  let(:null_pointer)   { FFI::Pointer.new(0) }
  let(:a_pointer)      { FFI::Pointer.new(1) }

  let(:mock_offline_sync_status) do
    sync = Spotify::OfflineSyncStatus.new
    mock_offline_sync_status_hash.each_pair do |key, value|
      sync[key] = value
    end
    sync
  end

  let(:mock_offline_sync_status_hash) do
    {
      :queued_tracks => 1,
      :queued_bytes  => 2,
      :done_tracks   => 3,
      :done_bytes    => 4,
      :copied_tracks => 5,
      :copied_bytes  => 6,
      :error_tracks  => 8,
      :syncing       => false,
      :willnotcopy_tracks => 7
    }
  end

  let(:mock_session_object) do
    session = Hallon::Session.send(:allocate)
    sstatus = mock_offline_sync_status
    inbox   = mock_playlist
    session.instance_eval do
      @pointer = Spotify.mock_session(nil, :undefined, 60 * 60 * 24 * 30, sstatus, 7, 3, inbox)
    end
    session
  end
end

RSpec.configure do |config|
  config.before do
    Spotify.registry_add 'spotify:track:7N2Vc8u56VGA4KUrGbikC2', mock_track
    Spotify.registry_add 'spotify:user:burgestrand', mock_user
    Spotify.registry_add 'spotify:user:burgestrand:playlist:07AX9IY9Hqmj1RqltcG0fi', mock_playlist
    Spotify.registry_add 'spotify:user:burgestrand:starred', mock_playlist
  end

  config.after do
    Spotify.registry_clean
  end
end
