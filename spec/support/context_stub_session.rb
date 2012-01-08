shared_context "stubbed session", :stub_session do
  before do
    subject.stub(:session).and_return(session)
  end
end
