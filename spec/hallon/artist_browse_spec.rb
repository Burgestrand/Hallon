# coding: utf-8
describe Hallon::ArtistBrowse do
  subject do
    mock_session do
      artist = Hallon::Artist.new(mock_artist)
      Spotify.should_receive(:artistbrowse_create).and_return(mock_artistbrowse)
      Hallon::ArtistBrowse.new(artist)
    end
  end

  it { should be_loaded }
  its(:error)  { should eq :ok }
  its(:artist) { should eq Hallon::Artist.new(mock_artist) }

  its('portraits.size') { should eq 2 }
  its('portraits.to_a') do
    Hallon::Session.should_receive(:instance).exactly(2).times.and_return(session)

    subject.map{ |img| img.id(true) }.should eq [mock_image_id, mock_image_id]
  end

  specify 'portraits(false)' do
    links = []
    links << mock_image_link
    links << mock_image_link_two

    Spotify.should_receive(:link_create_from_artistbrowse_portrait!).and_return(*links)

    subject.portraits(false).to_a.should eq instantiate(Hallon::Link, mock_image_link, mock_image_link_two)
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
