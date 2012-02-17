# coding: utf-8
describe Hallon::User do
  it_should_behave_like "a Linkable object" do
    let(:spotify_uri) { "spotify:user:burgestrand" }
    let(:custom_object) { "burgestrand" }
  end

  describe "an instance" do
    let(:user) { Hallon::User.new(mock_user) }

    describe "#loaded?" do
      it "should return true as the user is loaded" do
        user.should be_loaded
      end
    end

    describe "#name" do
      it "should be the canonical name" do
        user.name.should eq "burgestrand"
      end
    end

    describe "#display_name" do
      it "should be the users’ display name" do
        user.display_name.should eq "Burgestrand"
      end
    end

    describe "#post" do
      let(:post) { mock_session { user.post(tracks) } }
      let(:tracks) { instantiate(Hallon::Track, mock_track, mock_track_two) }

      it "should post to the correct user" do
        post.recipient_name.should eq user.name
      end

      it "should post with the given message" do
        post.message.should be_nil
        stub_session { user.post("Hey ho!", tracks) }.message.should eq "Hey ho!"
      end

      it "should return nil on failure" do
        stub_session { user.post([]).should be_nil }
      end
    end

    describe "#starred" do
      let(:starred) { Hallon::Playlist.new("spotify:user:%s:starred" % user.name) }

      it "should return the users’ starred playlist" do
        session.login 'Kim', 'pass'
        session.should be_logged_in
        mock_session { user.starred.should eq starred }
      end

      it "should return nil if not logged in" do
        session.should_not be_logged_in
        mock_session { user.starred.should be_nil }
      end
    end

    describe "#published" do
      let(:published) { Hallon::PlaylistContainer.new(mock_container) }

      it "should return the playlist container of the user" do
        Spotify.registry_add("spotify:container:%s" % user.name, mock_container)

        session.login('burgestrand', '')
        mock_session { user.published.should eq published }
      end

      it "should return nil if not logged in" do
        Spotify.should_receive(:session_publishedcontainer_for_user_create).and_return(null_pointer)
        mock_session { user.published.should be_nil }
      end
    end
  end
end
