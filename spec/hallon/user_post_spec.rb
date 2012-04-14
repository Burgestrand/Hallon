# coding: utf-8

describe Hallon::User::Post do
  let(:post) do
    Hallon::User::Post.create("burgestrand", "These be some tight tracks, yo!", tracks)
  end

  let(:tracks) do
    [].tap do |tracks|
      tracks << Hallon::Track.new(mock_track)
      tracks << Hallon::Track.new(mock_track_two)
    end
  end

  specify { post.should be_a Hallon::Loadable }

  describe ".new" do
    it "should be private" do
      Hallon::User::Post.should_not respond_to :new
    end
  end

  describe ".create" do
    it "should return nil if the inboxpost failed" do
      Spotify.should_receive(:inbox_post_tracks).and_return(null_pointer)
      post.should be_nil
    end

    it "should allow you to post a single track" do
      post = Hallon::User::Post.create("burgestrand", nil, tracks[0])
      post.tracks.should eq tracks[0, 1]
    end
  end

  describe "#status" do
    it "should return the inbox post status" do
      post.status.should be :ok
    end
  end

  describe "#tracks" do
    it "should return an array of tracks posted" do
      post.tracks.should eq tracks
    end
  end

  describe "#loaded?" do
    it "should return true only if the status is ok" do
      post.should_receive(:status).and_return(:is_loading)
      post.should_not be_loaded
    end

    it "should be true if the inbox post operation has completed" do
      post.should be_loaded
    end
  end

  describe "#message" do
    it "should return the message sent with the post" do
      post.message.should eq "These be some tight tracks, yo!"
    end

    it "returns an empty string if no message was sent" do
      post = Hallon::User::Post.create("burgestrand", nil, tracks)
      post.message.should be_nil
    end
  end

  describe "#recipient" do
    it "should return the recipient" do
      post.recipient.should eq Hallon::User.new("burgestrand")
    end
  end

  describe "#recipient_name" do
    it "should return the username of the post recipient" do
      post.recipient_name.should eq "burgestrand"
    end
  end
end
