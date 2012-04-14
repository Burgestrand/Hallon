RSpec::Core::ExampleGroup.instance_eval do
  let(:mock_users) do
    {
      default: mock_user,
      empty:   mock_empty_user
    }
  end

  let(:mock_user) do
    Spotify.mock_user!("burgestrand", "Burgestrand", true)
  end

  let(:mock_empty_user) do
    Spotify.mock_user!(nil, nil, false)
  end

  let(:mock_user_raw) do
    FFI::Pointer.new(mock_user.address)
  end
end

RSpec.configure do |config|
  config.before do
    Spotify.registry_add 'spotify:user:burgestrand', mock_user
    Spotify.registry_add 'spotify:user:burgestrand:playlist:07AX9IY9Hqmj1RqltcG0fi', mock_playlist
    Spotify.registry_add 'spotify:user:burgestrand:starred', mock_playlist
  end
end
