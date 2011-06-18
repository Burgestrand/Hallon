describe Hallon::User do
  describe ".new" do
    it "should raise ArgumentError when given an invalid link" do
      expect { Hallon::User.new("invalid link") }.to raise_error ArgumentError
    end

    it "should raise ArgumentError when given a non-user link" do
      expect { Hallon::User.new("spotify:search:moo") }.to raise_error ArgumentError
    end
  end

  has_requirement "logged in" do
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
      before(:all) do
        @user = session.user
        session.process_events_on(:userinfo_updated) { @user.loaded? }
      end

      specify "its name should equal #{ENV['HALLON_USERNAME'].downcase}" do
        canonical_name = ENV['HALLON_USERNAME'].downcase
        @user.name.should match canonical_name
      end

      it "should have a picture" do
        @user.picture.should be_a String
      end
    end
  end
end
