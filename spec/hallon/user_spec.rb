# coding: utf-8
describe Hallon::User do
  it_should_behave_like "a Linkable object" do
    let(:spotify_uri) { "spotify:user:burgestrand" }
    let(:custom_object) { "burgestrand" }
  end

  describe "an instance", :logged_in => true do
    let(:user) { Hallon::User.new(mock_user) }

    describe "#to_link" do
      it "should return a Link for this user" do
        user.to_link.should eq "spotify:user:burgestrand"
      end
    end

    describe "#name" do
      it "should be able to get the display name" do
        user.name(:display).should eq "Burgestrand"
      end

      it "should be able to get the full name" do
        user.name(:full).should eq "Kim Burgestrand"
      end

      it "should get the canonical name when unspecified" do
        user.name.should eq "burgestrand"
      end

      it "should fail on invalid name types" do
        expect { user.name(:i_am_invalid) }.to raise_error
      end
    end

    describe "#picture" do
      it "should retrieve the user picture" do
        user.picture.should eq "https://secure.gravatar.com/avatar/b67b73b5b1fd84119ec788b1c3df02ad"
      end
    end

    describe "#post" do
      let(:post) { mock_session { user.post(tracks) } }
      let(:tracks) { instantiate(Hallon::Track, mock_track, mock_track_two) }

      it "should have an error status" do
        post.error.should eq :ok
      end

      it "should post to the correct user" do
        Spotify.should_receive(:inbox_post_tracks).with(any_args, user.name, any_args, any_args, any_args, any_args, any_args).and_return(null_pointer)
        mock_session { user.post(tracks) }
      end

      it "should use given message if available" do
        Spotify.should_receive(:inbox_post_tracks).with(any_args, any_args, any_args, any_args, "Hello there", any_args, any_args).and_return(null_pointer)
        mock_session { user.post("Hello there", tracks) }
      end

      it "should return nil on failure" do
        mock_session { user.post([]).should be_nil }
      end
    end
  end
end
