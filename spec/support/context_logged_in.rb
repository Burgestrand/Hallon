shared_context "logged in", :logged_in do
  before(:all) do
    unless session.logged_in?
      session.login ENV['HALLON_USERNAME'], ENV['HALLON_PASSWORD']
      logged_in = session.process_events_on(:logged_in) { |error| error }
      logged_in.should eq :ok

      finished = session.process_events_on(:connection_error) { |error| session.logged_in? or error }
      finished.should be_true
    end

    session.should be_logged_in
  end

  before(:each) { session.should be_logged_in }
end
