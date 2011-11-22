# coding: utf-8
describe Hallon::AlbumBrowse do
  let(:browse) do
    album = Hallon::Album.new(mock_album)
    mock_session { Hallon::AlbumBrowse.new(album) }
  end

  subject { browse }

  it { should be_loaded }
  its(:status) { should eq :ok }
  its(:album)  { should eq Hallon::Album.new(mock_album) }
  its(:artist) { should eq Hallon::Artist.new(mock_artist) }
  its('copyrights.size') { should eq 2 }
  its('copyrights.to_a') { should eq %w[Kim Elin] }
  its('tracks.size') { should eq 2 }
  its('tracks.to_a') { should eq instantiate(Hallon::Track, mock_track, mock_track_two) }
  its(:review) { should eq "This album is AWESOME" }

  describe "#request_duration" do
    it "should return the request duration in seconds" do
      browse.request_duration.should eq 2.751
    end

    it "should be nil if the request was fetched from local cache" do
      Spotify.should_receive(:albumbrowse_backend_request_duration).and_return(-1)
      browse.request_duration.should be_nil
    end
  end
end
