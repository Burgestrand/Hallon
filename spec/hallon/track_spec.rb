# coding: utf-8
describe Hallon::Track, :session => true do
  let(:artist) { Spotify.mock_artist("Artist", true) }
  let(:album)  { Spotify.mock_album("Album", artist, 2011, nil, :unknown, true, true) }

  subject do
    artists = FFI::MemoryPointer.new(:pointer)
    artists.write_pointer artist

    track = Spotify.mock_track(
      "Elucteene", # name
      1, artists, # num_artists, artists
      album, # album
      123_456, # duration
      42,  # popularity
      2, 7, # disc, index
      0, true  # error, loaded
    )

    artists.free

    Hallon::Track.new(track)
  end

  its(:name)   { should eq "Elucteene" }
  its(:disc)   { should be 2 }
  its(:index)  { should be 7 }
  its(:status) { should be :ok }

  its(:duration) { should eq 123.456 }
  its(:popularity) { should eq 0.42 }

  xit("artist.name") { should eq "Artist" }
  xit("album.name")  { should eq "Album"  }

  it { should be_loaded }

  describe "album" do
    it "should be an album when there is one" do

    end

    it "should be nil when there isn’t one" do
      Spotify.should_receive(:track_album).and_return(FFI::Pointer.new(0))

      subject.album.should be_nil
    end
  end

  describe "to_link" do
    before(:each) { Hallon::Link.stub(:new) }

    it "should pass the current offset by default" do
      Spotify.should_receive(:link_create_from_track_and_offset).with(subject.pointer, 10_000)
      subject.should_receive(:offset).and_return(10)

      subject.to_link
    end

    it "should accept offset as parameter" do
      Spotify.should_receive(:link_create_from_track_and_offset).with(subject.pointer, 1_337_000)
      subject.should_not_receive(:offset)

      subject.to_link(1337)
    end
  end

  describe "offset" do
    let(:without_offset) { 'spotify:track:7N2Vc8u56VGA4KUrGbikC2' }
    let(:with_offset) { without_offset + '#1:00' }

    specify "with offset" do
      Hallon::Track.new(with_offset).offset.should eq 60
    end

    specify "without offset" do
      Hallon::Track.new(without_offset).offset.should eq 0
    end
  end

  describe "a local track" do
    subject do
      Hallon::Track.local "Title", "Artist", "Coolio", 100
    end

    its(:name) { should eq "Title" }
    pending("artist.name") { should eq "Artist" }
    pending("album.name") { should eq "Album" }
    its(:duration) { should eq 0.1 }
  end
end
