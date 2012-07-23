# coding: utf-8

RSpec::Core::ExampleGroup.instance_eval do
  let(:mock_images) do
    {
      default: mock_image,
      empty:   mock_empty_image
    }
  end

  let(:mock_image_uri) { "spotify:image:#{mock_image_hex}" }
  let(:mock_image_hex) { "3ad93423add99766e02d563605c6e76ed2b0e400" }
  let(:mock_image_id)  { ":\xD94#\xAD\xD9\x97f\xE0-V6\x05\xC6\xE7n\xD2\xB0\xE4\0".force_encoding("BINARY") }

  let(:mock_image) do
    Spotify.mock_image_create(mock_image_id, :jpeg, File.size(fixture_image_path), File.read(fixture_image_path), :ok)
  end

  let(:mock_empty_image) do
    Spotify.mock_image_create(mock_image_id, :jpeg, 0, nil, :ok)
  end

  let(:mock_image_id_pointer) do
    FFI::MemoryPointer.from_string(mock_image_id)
  end

  let(:mock_image_link) do
    Spotify.link_create_from_string(mock_image_uri)
  end

  let(:mock_image_link_two) do
    Spotify.link_create_from_string("spotify:image:ce9da340323614dc95ae96b68843b1c726dc5c8a")
  end
end
