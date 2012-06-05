describe Spotify do
  describe Spotify::CallbackStruct do
    subject { Spotify::SessionCallbacks.new }
    it { should be_a Spotify::CallbackStruct }

    it "should raise an error if given a callback of the wrong arity" do
      callback = lambda { |x| }
      expect { subject[:logged_in] = callback }.to raise_error(ArgumentError, /takes 2 arguments/)
    end
  end
end
