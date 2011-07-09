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
    let(:link) { Hallon::Link.new("spotify:user:burgestrand") }
    let(:user) { Hallon::User.new(link) }
    subject { user }

    before(:all) do
      session.process_events_on(:userinfo_updated) { user.loaded? }
    end

    describe "#to_link" do
      it "should return a Link for this user" do
        user.to_link.should eq link
      end
    end
  end
end
