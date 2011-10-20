# coding: utf-8
describe Hallon::Track do
  it_should_behave_like "a Linkable object" do
    let(:spotify_uri) { "spotify:track:7N2Vc8u56VGA4KUrGbikC2#01:00" }
  end

  subject { Hallon::Track.new(mock_track) }

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
      session.should_receive(:unstar).with(subject)
      subject.starred = false
    end

    it "should delegate to session to star" do
      session.should_receive(:star).with(subject)
      subject.starred = true
    end

    it "should change starred status of track" do
      subject.should be_starred
      subject.starred = false
      subject.should_not be_starred
    end
  end

  describe "session bound queries" do
    subject { Hallon::Track.new(mock_track) }
    around  { |test| mock_session(&test) }

    it { should be_available }
    it { should_not be_local }
    it { should be_autolinked }
    it { should be_starred }
  end

  describe "album" do
    it "should be an album when there is one" do
      subject.album.should eq Hallon::Album.new(mock_album)
    end

    it "should be nil when there isn’t one" do
      Spotify.should_receive(:track_album).and_return(FFI::Pointer.new(0))
      subject.album.should be_nil
    end
  end

  describe "to_link" do
    before(:each) { Hallon::Link.stub(:new) }
    let(:mock_link) { FFI::Pointer.new(1) }

    it "should pass the current offset by default" do
      Spotify.should_receive(:link_create_from_track).with(subject.pointer, 10_000).and_return(mock_link)
      subject.should_receive(:offset).and_return(10)

      subject.to_link
    end

    it "should accept offset as parameter" do
      Spotify.should_receive(:link_create_from_track).with(subject.pointer, 1337_000).and_return(mock_link)
      subject.should_not_receive(:offset)

      subject.to_link(1337)
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
