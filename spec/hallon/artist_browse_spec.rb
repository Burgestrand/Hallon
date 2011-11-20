# coding: utf-8
describe Hallon::ArtistBrowse do
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
    mock_session(2) { subject.map{ |img| img.id(true) }.should eq [mock_image_id, mock_image_id] }
  end

  specify 'portraits(false)' do
    browse.portraits(false)[0].should eq Hallon::Link.new(mock_image_link)
  end

  its('tracks.size') { should eq 2 }
  its('tracks.to_a') { should eq [mock_track, mock_track_two].map{ |p| Hallon::Track.new(p) } }
  its('albums.size') { should eq 1 }
  its('albums.to_a') { should eq [Hallon::Album.new(mock_album)] }
  its('similar_artists.size') { should eq 2 }
  its('similar_artists.to_a') { should eq [mock_artist, mock_artist_two].map{ |p| Hallon::Artist.new(p) } }
  its(:biography) { should eq 'grew up in DA BLOCK' }

  describe '.types' do
    subject { Hallon::ArtistBrowse.types }

    it { should be_an Array }
    it { should include :full }
  end
end
