# coding: utf-8
describe Hallon::User do
  let(:user) do
    Hallon::User.new(mock_users[:default])
  end

  let(:empty_user) do
    Hallon::User.new(mock_users[:empty])
  end

  specify { user.should be_a Hallon::Loadable }

  it_should_behave_like "a Linkable object" do
    let(:spotify_uri) { "spotify:user:burgestrand" }
    let(:custom_object) { "burgestrand" }
  end

  describe "#loaded?" do
    it "should return true as the user is loaded" do
      user.should be_loaded
    end
  end

  describe "#name" do
    it "should be the canonical name" do
      user.name.should eq "burgestrand"
    end

    it "returns an empty string if the name is not available" do
      empty_user.name.should be_empty
    end
  end

  describe "#display_name" do
    it "should be the users’ display name" do
      user.display_name.should eq "Burgestrand"
    end

    it "returns an empty string if the display name is not available" do
      empty_user.name.should be_empty
    end
  end

  describe "#post" do
    let(:post) { user.post(tracks) }
    let(:tracks) { instantiate(Hallon::Track, mock_track, mock_track_two) }

    it "should post to the correct user" do
      post.recipient_name.should eq user.name
    end

    it "should post with the given message" do
      post.message.should be_nil
      user.post("Hey ho!", tracks).message.should eq "Hey ho!"
    end

    it "should return nil on failure" do
      user.post([]).should be_nil
    end
  end

  describe "#starred" do
    let(:starred) { Hallon::Playlist.new("spotify:user:%s:starred" % user.name) }

    it "should return the users’ starred playlist" do
      session.login 'Kim', 'pass'
      session.should be_logged_in
      user.starred.should eq starred
    end

    it "should return nil if not available" do
      empty_user.starred.should be_nil
    end
  end

  describe "#published" do
    let(:published) { Hallon::PlaylistContainer.new(mock_container) }

    it "should return the playlist container of the user" do
      Spotify.registry_add("spotify:container:%s" % user.name, mock_container)

      session.login('burgestrand', 'pass')
      user.published.should eq published
    end

    it "should return nil if not logged in" do
      empty_user.published.should be_nil
    end
  end
end
