
describe Hallon::Session do
  before :all do
    @session = Hallon::Session.instance
  end

  it "should not be logged in" do
    @session.logged_in?.should equal false
  end

  it "can log in" do
    @session.logged_in?.should equal false
    @session.login(USERNAME, PASSWORD)
    @session.logged_in?.should equal true
  end

  it "can log out" do
    @session.logged_in?.should equal true
    @session.logout
    @session.logged_in?.should equal false
  end
end