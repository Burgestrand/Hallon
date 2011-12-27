# coding: utf-8
describe Hallon::ArtistBrowse do
  describe ".new" do
    it "should raise an error if the browse request failed" do
      Spotify.should_receive(:artistbrowse_create).and_return(null_pointer)
      expect { mock_session { Hallon::ArtistBrowse.new(mock_artist) } }.to raise_error(FFI::NullPointerError)
    end

    it "should raise an error given a non-album spotify pointer" do
      expect { Hallon::ArtistBrowse.new(mock_album) }.to raise_error(TypeError)
    end
  end

  let(:browse) do
    artist = Hallon::Artist.new(mock_artist)
    mock_session { Hallon::ArtistBrowse.new(artist) }
  end

  subject { browse }

  it { should be_loaded }
  its(:status) { should eq :ok }
  its(:artist) { should eq Hallon::Artist.new(mock_artist) }

  its('portraits.size') { should eq 2 }
  its('portraits.to_a') do
    stub_session { should eq instantiate(Hallon::Image, mock_image_id, mock_image_id) }
  end

  its('portrait_links.size') { should eq 2 }
  its('portrait_links.to_a') { should eq instantiate(Hallon::Link, mock_image_link, mock_image_link) }

  its('tracks.size') { should eq 2 }
  its('tracks.to_a') { should eq [mock_track, mock_track_two].map{ |p| Hallon::Track.new(p) } }
  its('albums.size') { should eq 1 }
  its('albums.to_a') { should eq [Hallon::Album.new(mock_album)] }
  its('similar_artists.size') { should eq 2 }
  its('similar_artists.to_a') { should eq [mock_artist, mock_artist_two].map{ |p| Hallon::Artist.new(p) } }
  its(:biography) { should eq 'grew up in DA BLOCK' }

  describe "#request_duration" do
    it "should return the request duration in seconds" do
      browse.request_duration.should eq 2.751
    end

    it "should be nil if the request was fetched from local cache" do
      Spotify.should_receive(:artistbrowse_backend_request_duration).and_return(-1)
      browse.request_duration.should be_nil
    end
  end

  describe '.types' do
    subject { Hallon::ArtistBrowse.types }

    it { should be_an Array }
    it { should include :full }
  end
end
