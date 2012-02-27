# coding: utf-8

describe Hallon::Loadable do
  let(:session) { double(:session, :process_events => 5) }
  let(:loadable) do
    _session = session
    Class.new do
      include Hallon::Loadable

      define_method(:session) { _session }
    end.new
  end

  describe "#load" do
    it "should timeout if the object does not load in time" do
      Hallon.stub(:load_timeout).and_return(0.001)
      loadable.stub(:loaded?).and_return(false)
      expect { loadable.load }.to raise_error(Hallon::TimeoutError)
    end

    it "should use the Hallon.load_timeout by default" do
      Hallon.should_receive(:load_timeout).and_return(0.075)
      Timeout.should_receive(:timeout).with(0.075, Hallon::TimeoutError).and_yield
      loadable.stub(:loaded?).and_return(true)
      loadable.load
    end

    it "should return the object in question on success" do
      loadable.stub(:loaded?).and_return(true)
      loadable.load.should eq loadable
    end

    it "should raise an error when status is an error" do
      session.should_receive(:process_events).once
      loadable.stub(:loaded?).and_return(false)
      loadable.stub(:status).and_return(:other_permanent)
      expect { loadable.load }.to raise_error(Hallon::Error)
    end

    it "should not raise an error when status is_loading" do
      loadable.stub(:loaded?).and_return(false, true)
      loadable.stub(:status).and_return(:is_loading)
      loadable.load.should eq loadable
    end
  end
end
