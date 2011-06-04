shared_examples_for "existing session" do
  before(:all) { @session = session }
end

shared_examples_for "logged in" do
  before(:all) do
    session.login ENV['HALLON_USERNAME'], ENV['HALLON_PASSWORD']

    session.process_events_on(:logged_in) do
      session.logged_in?
    end

    session.should be_logged_in
  end

  before(:each) do
    session.should be_logged_in
  end
end
