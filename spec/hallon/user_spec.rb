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

  context :logged_in => true do
    describe "creating a User" do
      context "from Spotify URI" do
        before(:all) do
          @user = Hallon::User.new("spotify:user:burgestrand")
          session.process_events_on(:userinfo_updated) { @user.loaded? }
        end

        specify "its name should equal burgestrand" do
          @user.name.should eq "burgestrand"
        end
      end

      context "from Link" do
        before(:all) do
          link = Hallon::Link.new("spotify:user:burgestrand")
          @user = Hallon::User.new(link)
          session.process_events_on(:userinfo_updated) { @user.loaded? }
        end

        specify "its name should equal burgestrand" do
          @user.name.should eq "burgestrand"
        end
      end

      context "from Session#user" do
        subject { @user }

        before(:all) do
          @user = session.user
          session.process_events_on(:userinfo_updated) { @user.loaded? }
        end

        it { should be_loaded }
      end
    end

    specify "#to_link should return the Link for the users’ Spotify URI" do
      link = Hallon::Link.new("spotify:user:burgestrand")

      user = Hallon::User.new(link)
      session.process_events_on(:userinfo_updated) { user.loaded? }

      user.to_link.should eq link
    end
  end
end
