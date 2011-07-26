# coding: utf-8
describe Hallon::Track, :session => true do
  subject { Hallon::Track.new(mock_track) }

  its(:name)   { should eq "They" }
  its(:disc)   { should be 2 }
  its(:index)  { should be 7 }
  its(:status) { should be :ok }

  its(:duration) { should eq 123.456 }
  its(:popularity) { should eq 0.42 }

  pending("album.name")  { should eq "Finally Woken"  }
  pending("artist.name") { should eq "Jem" }

  it { should be_loaded }

  describe "album" do
    it "should be an album when there is one", :pending => true do
      subject.album.should eq Hallon::Album.new(mock_album)
    end

    it "should be nil when there isn’t one" do
      Spotify.should_receive(:track_album).and_return(FFI::Pointer.new(0))
      subject.album.should be_nil
    end
  end

  describe "to_link" do
    before(:each) { Hallon::Link.stub(:new) }

    it "should pass the current offset by default" do
      Spotify.should_receive(:link_create_from_track).with(subject.send(:pointer), 10_000)
      subject.should_receive(:offset).and_return(10)

      subject.to_link
    end

    it "should accept offset as parameter" do
      Spotify.should_receive(:link_create_from_track).with(subject.send(:pointer), 1_337_000)
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
      Hallon::Track.local "Nissy", "Emmy", "Coolio", 100
    end

    its(:name) { should eq "Nissy" }
    pending("album.name") { should eq "Coolio" }
    pending("artist.name") { should eq "Emmy" }
    its(:duration) { should eq 0.1 }
  end
end
