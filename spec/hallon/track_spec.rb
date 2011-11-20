# coding: utf-8
describe Hallon::Track do
  it_should_behave_like "a Linkable object" do
    let(:spotify_uri) { "spotify:track:7N2Vc8u56VGA4KUrGbikC2#01:00" }
  end

  let(:track) { Hallon::Track.new(mock_track) }
  subject { track }

  it { should be_loaded }
  its(:name)   { should eq "They" }
  its(:disc)   { should be 2 }
  its(:index)  { should be 7 }
  its(:status) { should be :ok }
  its(:duration)   { should eq 123.456 }
  its(:popularity) { should eq 0.42 }
  its(:album) { should eq Hallon::Album.new(mock_album) }
  its(:artist) { should eq Hallon::Artist.new(mock_artist) }
  its('artists.size') { should eq 2 }
  its('artists.to_a') { should eq [mock_artist, mock_artist_two].map{ |p| Hallon::Artist.new(p) } }

  describe "#starred=" do
    around { |test| mock_session(&test) }

    it "should delegate to session to unstar" do
      session.should_receive(:unstar).with(track)
      track.starred = false
    end

    it "should delegate to session to star" do
      session.should_receive(:star).with(track)
      track.starred = true
    end

    it "should change starred status of track" do
      track.should be_starred
      track.starred = false
      track.should_not be_starred
    end
  end

  describe "session bound queries" do
    subject { Hallon::Track.new(mock_track) }
    around  { |test| mock_session(&test) }

    it { should be_available }
    it { should_not be_local }
    it { should be_autolinked }
    it { should be_starred }

    its(:availability) { should eq :available }
  end

  describe "album" do
    it "should be an album when there is one" do
      track.album.should eq Hallon::Album.new(mock_album)
    end

    it "should be nil when there isn’t one" do
      Spotify.should_receive(:track_album).and_return(null_pointer)
      track.album.should be_nil
    end
  end

  describe "to_link" do
    it "should pass the current offset by default" do
      track.should_receive(:offset).and_return(10)
      track.to_link.to_str.should match /#00:10/
    end

    it "should accept offset as parameter" do
      track.should_not_receive(:offset)
      track.to_link(1337).to_str.should match /#22:17/
    end
  end

  describe "#placeholder?" do
    let(:yes) { Hallon::Track.new(mock_track_two) }

    it "should return the placeholder status of the track" do
      yes.should be_placeholder
      track.should_not be_placeholder
    end
  end

  describe "#unwrap" do
    let(:track) { Hallon::Track.new(mock_track_two) }
    let(:playlist) { Spotify.link_create_from_string!('spotify:user:burgestrand:playlist:07AX9IY9Hqmj1RqltcG0fi') }
    let(:artist)   { Spotify.link_create_from_string!('spotify:artist:3bftcFwl4vqRNNORRsqm1G') }
    let(:album)    { Spotify.link_create_from_string!('spotify:album:1xvnWMz2PNFf7mXOSRuLws') }

    it "should unwrap a playlist placeholder into a playlist" do
      Spotify.should_receive(:link_create_from_track!).and_return(playlist)
      mock_session { track.unwrap.should eq Hallon::Playlist.new(playlist) }
    end

    it "should unwrap an album placeholder into an album" do
      Spotify.should_receive(:link_create_from_track!).and_return(album)
      track.unwrap.should eq Hallon::Album.new(album)
    end

    it "should unwrap an artist placeholder into an artist" do
      Spotify.should_receive(:link_create_from_track!).and_return(artist)
      track.unwrap.should eq Hallon::Artist.new(artist)
    end
  end

  describe "#offline_status" do
    it "should return the tracks’ offline status" do
      track.offline_status.should eq :done
    end
  end

  describe "offset" do
    let(:without_offset) { 'spotify:track:7N2Vc8u56VGA4KUrGbikC2' }
    let(:with_offset)    { without_offset + '#1:00' }

    specify "with offset" do
      Hallon::Track.new(with_offset).offset.should eq 60
    end

    specify "without offset" do
      Hallon::Track.new(without_offset).offset.should eq 0
    end

    specify "when instantiated from a pointer" do
      Hallon::Track.new(mock_track).offset.should eq 0
    end
  end

  describe "a local track" do
    subject do
      Hallon::Track.local "Nissy", "Emmy", "Coolio", 100
    end

    its(:name) { should eq "Nissy" }
    its("album.name") { should eq "Coolio" }
    its("artist.name") { should eq "Emmy" }
    its(:duration) { should eq 0.1 }

    it do
      Hallon::Session.should_receive(:instance).and_return(session)
      should be_local
    end
  end
end
