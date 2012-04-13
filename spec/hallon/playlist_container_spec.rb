# coding: utf-8
describe Hallon::PlaylistContainer do
  it { should be_a Hallon::Loadable }

  let(:container) { Hallon::PlaylistContainer.new(mock_container) }

  subject { container }

  it { should be_loaded }
  its(:owner) { should eq Hallon::User.new("burgestrand") }
  its(:size) { should eq 4 }

  describe "#add" do
    context "given a string that’s not a valid spotify playlist uri" do
      it "should create a new playlist at the end of the container" do
        expect do
          playlist = container.add("Bogus")

          playlist.name.should eq "Bogus"
          container.contents[-1].should eq playlist
        end.to change{ container.size }.by(1)
      end

      it "should raise an error if the name is invalid" do
        expect { container.add(" ") }.to raise_error(ArgumentError)
      end
    end

    context "given a string that’s a valid spotify playlist uri" do
      it "should add the existing Playlist at the end of the container" do
        playlist_uri = "spotify:user:burgestrand:playlist:07AX9IY9Hqmj1RqltcG0fi"
        playlist = Hallon::Playlist.new(playlist_uri)

        expect do
          new_playlist = container.add(playlist_uri)

          new_playlist.should eq playlist
          container.contents[-1].should eq playlist
        end.to change{ container.size }.by(1)
      end

      it "should create a new playlist at the end of the container if forced to" do
        playlist_uri = "spotify:user:burgestrand:playlist:07AX9IY9Hqmj1RqltcG0fi"

        expect do
          new_playlist = container.add(playlist_uri, :force_create)

          new_playlist.name.should eq playlist_uri
          container.contents[-1].should eq new_playlist
        end.to change{ container.size }.by(1)
      end
    end

    context "given an existing playlist" do
      it "should add it to the container if it’s a playlist" do
        expect do
          container.add Hallon::Playlist.new(mock_playlist)
          container.contents[-1].should eq Hallon::Playlist.new(mock_playlist)
        end.to change{ container.size }.by(1)
      end

      it "should add it to the container if it’s a link" do
        expect do
          container.add Hallon::Link.new("spotify:user:burgestrand:playlist:07AX9IY9Hqmj1RqltcG0fi")
          container.contents[-1].should eq Hallon::Playlist.new(mock_playlist)
        end.to change{ container.size }.by(1)
      end
    end

    it "should return nil when failing to add the item" do
      Spotify.should_receive(:playlistcontainer_add_playlist).and_return(null_pointer)
      playlist = container.add Hallon::Link.new("spotify:user:burgestrand")
      playlist.should be_nil
    end
  end

  describe "#add_folder" do
    it "should add a folder at the end of the container with the given name" do
      size   = container.size
      folder = container.add_folder "Bonkers"

      folder.name.should eq "Bonkers"
      folder.begin.should be size
      folder.end.should be(size + 1)

      container.contents[-1].should eq folder
    end
  end

  describe "#insert_folder" do
    it "should add a folder at the specified index" do
      folder = container.insert_folder(2, "Mipmip")

      folder.name.should eq "Mipmip"
      folder.begin.should be 2
      folder.end.should be 3

      container.contents[2].should eq folder
      container.contents[3].should eq folder
    end
  end

  describe "#remove" do
    it "should remove the playlist at the given index" do
      expect { container.remove(0) }.to change { container.size }.by(-1)
    end

    it "should remove the matching :end_folder if removing a :start_folder" do
      container.contents.map(&:class).should eq [Hallon::Playlist, Hallon::PlaylistContainer::Folder, Hallon::Playlist, Hallon::PlaylistContainer::Folder]
      expect { container.remove(1) }.to change { container.size }.by(-2)
      container.contents.map(&:class).should eq [Hallon::Playlist, Hallon::Playlist]
    end

    it "should remove the matching :start_folder if removing a :end_folder" do
      container.contents.map(&:class).should eq [Hallon::Playlist, Hallon::PlaylistContainer::Folder, Hallon::Playlist, Hallon::PlaylistContainer::Folder]
      expect { container.remove(3) }.to change { container.size }.by(-2)
      container.contents.map(&:class).should eq [Hallon::Playlist, Hallon::Playlist]
    end

    it "should raise an error if the index is out of range" do
      expect { container.remove(-1) }.to raise_error(Hallon::Error)
    end
  end

  describe "#move" do
    it "should move the playlist from the old index to the new index" do
      playlist     = container.contents[0]
      playlist_two = container.contents[2]

      container.contents.map(&:class).should eq [Hallon::Playlist, Hallon::PlaylistContainer::Folder, Hallon::Playlist, Hallon::PlaylistContainer::Folder]

      container.move(0, 1).should eq playlist
      container.contents.map(&:class).should eq [Hallon::PlaylistContainer::Folder, Hallon::Playlist, Hallon::Playlist, Hallon::PlaylistContainer::Folder]
      container.contents[1].should eq playlist

      container.move(2, 0).should eq playlist_two
      container.contents.map(&:class).should eq [Hallon::Playlist, Hallon::PlaylistContainer::Folder, Hallon::Playlist, Hallon::PlaylistContainer::Folder]
    end

    it "should raise an error if the operation failed" do
      expect { container.move(0, -1) }.to raise_error(Hallon::Error)
    end
  end

  describe "#can_move?" do
    it "should be true if the operation can be performed" do
      expect { container.can_move?(0, 1).should be_true }.to_not change { container.contents.to_a }
    end

    it "should be false if the operation cannot be performed" do
      expect { container.can_move?(0, -1).should be_false }.to_not change { container.contents.to_a }
    end
  end

  describe "#contents" do
    it "should support retrieving playlists" do
      container.contents[0].should eq Hallon::Playlist.new(mock_playlist)
    end

    it "should support retrieving folders from their start" do
      folder = Hallon::PlaylistContainer::Folder.new(container.pointer, 1..3)
      container.contents[1].should eq folder
    end

    it "should support retrieving folders from their end" do
      folder = Hallon::PlaylistContainer::Folder.new(container.pointer, 1..3)
      container.contents[3].should eq folder
    end
  end

  describe Hallon::PlaylistContainer::Folder do
    subject { container.contents[1] }
    let(:folder) { subject }

    its(:id)    { should be 1337 }
    its(:name)  { should eq "Boogie" }
    its(:begin) { should be 1 }
    its(:end)   { should be 3 }

    describe "#moved?" do
      it "should return true if the folder has moved" do
        folder.should_not be_moved
        container.move(folder.begin, 0).id.should eq folder.id
        folder.should be_moved
        container.move(0, 1).id.should eq folder.id
        folder.should_not be_moved
      end
    end

    describe "#contents" do
      it "should be a collection of folders and playlists" do
        folder.contents.should eq container.contents[2, 1]
      end
    end

    describe "#rename" do
      it "should not touch the original folder data (but it should remove it)" do
        container.contents.should include(folder)

        folder.rename("Hiphip")

        folder.id.should eq 1337
        folder.name.should eq "Boogie"
        folder.begin.should be 1
        folder.end.should be 3

        container.contents.should_not include(folder)
      end

      it "should return a new folder with the new data" do
        new_folder = folder.rename("Hiphip")

        new_folder.id.should_not eq 1337
        new_folder.name.should eq "Hiphip"
        new_folder.begin.should be 1
        new_folder.end.should be 3
      end

      it "should raise an error if the folder has moved" do
        container.move(folder.begin, 0)
        expect { folder.rename "Boogelyboogely" }.to raise_error(IndexError)
      end
    end
  end
end
