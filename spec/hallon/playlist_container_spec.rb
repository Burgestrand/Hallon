# coding: utf-8
describe Hallon::PlaylistContainer do
  let(:container) { Hallon::PlaylistContainer.new(mock_container) }

  subject { container }

  it { should be_loaded }
  its(:owner) { should eq Hallon::User.new("burgestrand") }
  its(:size) { should eq 1 }

  describe "#add" do
    context "given a string" do
      it "should create a new Playlist at the end of the playlist" do
        expect do
          playlist = container.add("Bogus")

          playlist.name.should eq "Bogus"
          container.contents[-1].should eq playlist
        end.to change{ container.size }.by(1)
      end
    end

    it "should add the given Playlist to the end of the container" do
      expect do
        playlist = container.add Hallon::Playlist.new(mock_playlist)
        container.contents[-1].should eq Hallon::Playlist.new(mock_playlist)
      end.to change{ container.size }.by(1)
    end

    it "should add the given Playlist Link to the end of the container" do
      expect do
        playlist = container.add Hallon::Link.new("spotify:user:burgestrand:playlist:07AX9IY9Hqmj1RqltcG0fi")
        container.contents[-1].should eq Hallon::Playlist.new(mock_playlist)
      end.to change{ container.size }.by(1)
    end

    it "should return nil when failing to add the item" do
      Spotify.should_receive(:playlistcontainer_add_playlist).and_return(null_pointer)
      playlist = container.add Hallon::Link.new("spotify:user:burgestrand")
      playlist.should be_nil
    end
  end

  describe "#insert" do
    it "should add the given Playlist to the given index"
    it "should add the given Folder to the given index"
  end

  describe "#remove" do
    it "should remove the playlist at the given index"
    it "should remove the matching :folder_end if removing a folder"
  end

  describe "#move" do
    it "should move the entity at the given index"
  end

  describe "#contents" do
    #
    # (0) playlist: Hello
    # (1) start_folder: Hi
    # (2) playlist: inside Hi
    # (3) start_folder: Ho
    # (4) playlist: inside HiHo
    # (5) end_folder
    # (6) playlist: inside Hi2
    # (7) end_folder
    # (8) playlist: World
    #
    # … should become:
    #
    # (0) Playlist #1
    # (1) Folder #1…#7
    # (2) Playlist #2
    # (3) Folder #3…#5
    # (4) Playlist #4
    # (5) Folder #3…#5
    # (6) Playlist #6
    # (7) Folder #1…#7
    # (8) Playlist #8
    #
    it "should be a collection of folders and playlists"

    it "should support retrieving playlists" do
      container.contents[0].should eq Hallon::Playlist.new(mock_playlist)
    end
  end

  describe Hallon::PlaylistContainer::Folder, :pending do
    subject { container.contents[1] }

    its(:id)   { should be 1337 }
    its(:name) { should be "Awesome folder" }

    describe "#contents" do
      it "should be a collection of folders and playlists"
    end

    describe "#rename" do
      it "should rename the playlist container"
    end
  end
end
