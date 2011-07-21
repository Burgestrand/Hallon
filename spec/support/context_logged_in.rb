shared_context "logged in", :logged_in do
  before(:all) do
    session.login 'username', 'password'
    session.should be_logged_in
  end

  after(:all) do
    session.logout
    session.should_not be_logged_in
  end
end
