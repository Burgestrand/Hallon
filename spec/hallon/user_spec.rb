# coding: utf-8
describe Hallon::User do
  describe ".new" do
    it "should raise ArgumentError when given an invalid link" do
      expect { Hallon::User.new("invalid link") }.to raise_error ArgumentError
    end

    it "should raise ArgumentError when given a non-user link" do
      expect { Hallon::User.new("spotify:search:moo") }.to raise_error ArgumentError
    end
  end

  describe "creating a User", :logged_in => true do
    context ".new", "from a Spotify URI" do
      subject { Hallon::User.new("spotify:user:burgestrand") }
      it_should_behave_like "a loadable object"
    end

    context ".new", "from a Link" do
      subject { Hallon::User.new Hallon::Link.new("spotify:user:burgestrand") }
      it_should_behave_like "a loadable object"
    end

    context "from Session#user" do
      subject { session.user }
      it_should_behave_like "a loadable object"
    end
  end

  describe "an instance", :logged_in => true do
    let(:user) do
      user = Spotify.mock_user(
        "burgestrand", "Burgestrand", "Kim Burgestrand",
        "https://secure.gravatar.com/avatar/b67b73b5b1fd84119ec788b1c3df02ad",
        :none, true
      )
      Hallon::User.new(user)
    end

    subject { user }

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
  end
end
