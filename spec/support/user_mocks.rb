RSpec::Core::ExampleGroup.instance_eval do
  let(:mock_users) do
    {
      default: mock_user,
      empty:   mock_empty_user
    }
  end

  let(:mock_user) do
    Spotify.mock_user_create("burgestrand", "Burgestrand", true)
  end

  let(:mock_empty_user) do
    Spotify.mock_user_create(nil, nil, false)
  end

  let(:mock_user_raw) do
    FFI::Pointer.new(mock_user.address)
  end
end
