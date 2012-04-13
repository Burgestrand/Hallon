# coding: utf-8
require 'time'

describe Hallon::Playlist do
  it { should be_a Hallon::Loadable }

  it_should_behave_like "a Linkable object" do
    let(:spotify_uri) { "spotify:user:burgestrand:playlist:07AX9IY9Hqmj1RqltcG0fi" }
    let(:described_class) { Hallon::Playlist }
  end

  subject { playlist }
  let(:playlist) do
    Hallon::Playlist.new(mock_playlists[:default])
  end

  let(:empty_playlist) do
    Hallon::Playlist.new(mock_playlists[:empty])
  end

  describe ".invalid_name?" do
    it "should return false if the name is valid" do
      Hallon::Playlist.invalid_name?("Moo").should be_false
    end

    it "should return an error message when the name is blank" do
      Hallon::Playlist.invalid_name?(" ").should match "blank"
    end

    it "should return an error message when the name is too long" do
      Hallon::Playlist.invalid_name?("Moo" * 256).should match "bytes"
    end
  end

  describe "#loaded?" do
    it "is true when the playlist is loaded" do
      playlist.should be_loaded
    end

    it "is false when the playlist is not loaded" do
      empty_playlist.should_not be_loaded
    end
  end

  describe "#name" do
    it "returns the playlist’s name as a string" do
      playlist.name.should eq "Megaplaylist"
    end

    it "returns an empty string when the playlist is not loaded" do
      empty_playlist.name.should be_empty
    end
  end

  describe "#owner" do
    it "returns the playlist’s owner" do
      playlist.owner.should eq Hallon::User.new(mock_user)
    end

    it "returns nil when the playlist is not loaded" do
      empty_playlist.owner.should be_nil
    end
  end

  describe "#description" do
    it "returns the playlist’s description" do
      playlist.description.should eq "Playlist description...?"
    end

    it "returns an empty string if the playlist is not loaded" do
      empty_playlist.description.should be_empty
    end
  end

  describe "#image" do
    it "returns the playlists’s image as an image" do
      playlist.image.should eq Hallon::Image.new("spotify:image:3ad93423add99766e02d563605c6e76ed2b0e400")
    end

    it "returns nil if the playlist is not loaded" do
      empty_playlist.image.should be_nil
    end
  end

  describe "#total_subscribers" do
    it "returns the total number of subscribers to the playlist" do
      playlist.total_subscribers.should eq 1000
    end

    it "returns zero if the playlist is not loaded" do
      empty_playlist.total_subscribers.should eq 0
    end
  end

  describe "#sync_progress" do
    it "returns the completed percentage of the playlist download" do
      playlist.sync_progress.should eq 67
    end

    it "returns zero if the playlist is not loaded" do
      empty_playlist.sync_progress.should eq 0
    end
  end

  describe "#size" do
    it "returns the number of tracks in the playlist" do
      playlist.size.should eq 4
    end

    it "returns zero if the playlist is not loaded" do
      empty_playlist.size.should eq 0
    end
  end

  describe "#collaborative?" do
    it "is true when the playlist is set to be collaborative" do
      playlist.should be_collaborative
    end
  end

  describe "#pending?" do
    it "is false when the playlist does not have pending updates" do
      playlist.should_not be_pending
    end
  end

  describe "#in_ram?" do
    it "is true when the playlist is loaded in memory" do
      playlist.should be_in_ram
    end
  end

  describe "#available_offline?" do
    it "is false when the playlist is not enabled for offline use" do
      playlist.should_not be_available_offline
    end
  end

  its('tracks.size') { should eq 4 }
  its('tracks.to_a') { should eq instantiate(Hallon::Playlist::Track, *(0...4).map { |index| [Spotify.playlist_track!(playlist.pointer, index), playlist.pointer, index] }) }

  describe "tracks#[]" do
    let(:track) { subject }
    subject { playlist.tracks[0] }

    it { should be_seen }
    its(:create_time) { should eq Time.parse("2009-11-04") }
    its(:creator)     { should eq Hallon::User.new(mock_user) }
    its(:message)     { should eq "message this, YO!" }

    describe "#seen=" do
      it "should raise an error if the track has moved" do
        track.should be_seen
        track.playlist.move(1, 0)
        expect { track.seen = false }.to raise_error(IndexError)
        track.should be_seen
      end

      it "should update the value of #seen?" do
        track.should be_seen
        track.seen = false
        track.should_not be_seen
      end
    end

    describe "#moved?" do
      it "should be true if the track has moved" do
        track.should_not be_moved
        track.playlist.move(1, 0)
        track.should be_moved
      end
    end
  end

  describe "#upload" do
    around(:each) do |example|
      Timeout.timeout(1) { example.run }
    end

    it "should raise an error if the playlist takes too long to load" do
      playlist.stub(:pending? => true)
      expect { playlist.upload(0.1) }.to raise_error(Hallon::TimeoutError)
    end
  end

  describe "#subscribers" do
    it "should return an array of names for the subscribers" do
      playlist.subscribers.should eq %w[Kim Elin Ylva]
    end

    it "should return an empty array when there are no subscribers" do
      empty_playlist.subscribers.should eq []
    end

    it "should return an empty array when subscriber fetching failed" do
      Spotify.should_receive(:playlist_subscribers).and_return(null_pointer)
      empty_playlist.subscribers.should eq []
    end
  end

  describe "#insert" do
    let(:tracks) { instantiate(Hallon::Track, mock_track, mock_track_two) }

    it "should add the given tracks to the playlist at correct index" do
      old_tracks = playlist.tracks.to_a
      new_tracks = old_tracks.insert(1, *tracks)
      playlist.insert(1, tracks)

      playlist.tracks.to_a.should eq new_tracks
    end

    it "should default to adding tracks at the end" do
      playlist.insert(tracks)
      playlist.tracks[2, 2].should eq tracks
    end

    it "should raise an error if the operation cannot be completed" do
      expect { playlist.insert(-1, nil) }.to raise_error(Hallon::Error)
    end
  end

  describe "#remove" do
    it "should remove the tracks at the given indices" do
      old_tracks = playlist.tracks.to_a
      new_tracks = [old_tracks[0], old_tracks[2]]

      playlist.remove(1, 3)
      playlist.tracks.to_a.should eq new_tracks
    end

    it "should raise an error if given invalid parameters" do
      expect { playlist.remove(-1) }.to raise_error(ArgumentError)
      expect { playlist.remove(playlist.size) }.to raise_error(ArgumentError)
    end
  end

  describe "#move" do
    it "should move the tracks at the given indices to their new location" do
      old_tracks = playlist.tracks.to_a
      new_tracks = [old_tracks[1], old_tracks[0], old_tracks[3], old_tracks[2]]

      playlist.move(2, [0, 3])
      playlist.tracks.to_a.should eq new_tracks
    end

    it "should raise an error if the operation cannot be completed" do
      expect { playlist.move(-1, [-1]) }.to raise_error(Hallon::Error)
    end
  end

  describe "#name=" do
    it "should set the new playlist name" do
      playlist.name.should eq "Megaplaylist"
      playlist.name = "Monoplaylist"
      playlist.name.should eq "Monoplaylist"
    end

    it "should fail given an empty name" do
      expect { playlist.name = "" }.to raise_error(ArgumentError)
    end

    it "should fail given a name of only spaces" do
      expect { playlist.name = " " }.to raise_error(ArgumentError)
    end

    it "should fail given a too long name" do
      expect { playlist.name = "a" * 256 }.to raise_error(ArgumentError)
      expect { playlist.name = "ä" * 200 }.to raise_error(ArgumentError)
    end
  end

  describe "#collaborative=" do
    it "should set the collaborative status" do
      playlist.should be_collaborative
      playlist.collaborative = false
      playlist.should_not be_collaborative
    end
  end

  describe "#autolink_tracks=" do
    it "should set autolink status" do
      Spotify.mocksp_playlist_get_autolink_tracks(playlist.pointer).should be_false
      playlist.autolink_tracks = true
      Spotify.mocksp_playlist_get_autolink_tracks(playlist.pointer).should be_true
    end
  end

  describe "#in_ram=" do
    it "should set in_ram status" do
      playlist.should be_in_ram
      playlist.in_ram = false
      playlist.should_not be_in_ram
    end
  end

  describe "#offline_mode=" do
    it "should set offline mode" do
      playlist.should_not be_available_offline
      playlist.offline_mode = true
      playlist.should be_available_offline
    end
  end

  describe "#update_subscribers" do
    it "should ask libspotify to update the subscribers" do
      expect { playlist.update_subscribers }.to_not raise_error
    end

    it "should return the playlist" do
      playlist.update_subscribers.should eq playlist
    end
  end

  describe "offline status methods" do
    def symbol_for(number)
      Spotify.enum_type(:playlist_offline_status)[number]
    end

    specify "#available_offline?" do
      Spotify.should_receive(:playlist_get_offline_status).and_return symbol_for(1)
      should be_available_offline
    end

    specify "#syncing?" do
      Spotify.should_receive(:playlist_get_offline_status).and_return symbol_for(2)
      should be_syncing
    end

    specify "#waiting?" do
      Spotify.should_receive(:playlist_get_offline_status).and_return symbol_for(3)
      should be_waiting
    end

    specify "#offline_mode?" do
      Spotify.should_receive(:playlist_get_offline_status).and_return symbol_for(0)
      should_not be_offline_mode
    end
  end
end
