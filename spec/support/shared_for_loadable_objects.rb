shared_examples_for "a loadable object" do
  before(:all) do
    session.process_events_on { subject.loaded? }
  end

  it { should be_loaded }
end
