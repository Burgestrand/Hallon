# coding: utf-8
describe Hallon::AlbumBrowse, :pending => true do
  subject { Hallon::AlbumBrowse.new(mock_albumbrowse) }

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
