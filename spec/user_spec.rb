describe Hallon::User do
  before :all do
    @session = Hallon::Session.instance.login(USERNAME, PASSWORD)
    @session.logged_in?.should equal true
  end
  
  after :all do
    @session.logout
  end
  
  it "should have a name" do
    user = @session.user
    name = user.name
    
    name.length.should be > 0
    user.send(user.loaded? ? :should_not : :should) == user.name(true)
  end
end