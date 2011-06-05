describe Hallon::User do
  has_requirement "logged in" do
    before(:all) do
      @user = session.user
      session.process_events_on(:userinfo_updated) { @user.loaded? }
    end

    it "should be loaded" do
      @user.should be_loaded
    end

    specify "its name should equal #{ENV['HALLON_USERNAME']}" do
      canonical_name = Regexp.new(ENV['HALLON_USERNAME'], Regexp::IGNORECASE)
      @user.name.should match canonical_name
    end

    # TODO: how do we test for this?!
    it "should have a picture" do
      @user.picture.should be_a String
    end
  end
end
