# coding: utf-8
describe Hallon::AlbumBrowse do
  subject do
    Hallon::Session.should_receive(:instance).and_return(session)
    album = Hallon::Album.new(mock_album)
    Spotify.should_receive(:albumbrowse_create).and_return(mock_albumbrowse)
    Hallon::AlbumBrowse.new(album)
  end

  it { should be_loaded }
  its(:error)  { should eq :ok }
  its(:album)  { should eq Hallon::Album.new(mock_album) }
  its(:artist) { should eq Hallon::Artist.new(mock_artist) }
  its('copyrights.size') { should eq 2 }
  its('copyrights.to_a') { should eq %w[Kim Elin] }
  its('tracks.size') { should eq 2 }
  its('tracks.to_a') { should eq [mock_track, mock_track_two].map{ |p| Hallon::Track.new(p) } }
  its(:review) { should eq "This album is AWESOME" }
end
