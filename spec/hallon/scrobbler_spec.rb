describe Hallon::Scrobbler do
  let(:scrobbling) { Hallon::Scrobbler.new(:facebook) }

  describe ".providers" do
    it "returns a list of social providers" do
      Hallon::Scrobbler.providers.should include :facebook
    end
  end

  describe "#initialize" do
    it "raises an error if given an invalid social provider" do
      expect { Hallon::Scrobbler.new(:invalid_provider) }.to raise_error(ArgumentError, /social provider/)
    end
  end

  describe "#provider" do
    it "returns the social provider the scrobbler was instantiated with" do
      scrobbling.provider.should eq :facebook
    end
  end

  describe "#possible?" do
    it "returns true if scrobbling is possible" do
      Spotify.mocksp_session_set_is_scrobbling_possible(session.pointer, scrobbling.provider, true)
      scrobbling.should be_possible
    end

    it "returns false if scrobbling is not possible" do
      Spotify.mocksp_session_set_is_scrobbling_possible(session.pointer, scrobbling.provider, false)
      scrobbling.should_not be_possible
    end

    it "raises an error if libspotify does not like us" do
      Spotify.should_receive(:session_is_scrobbling_possible).and_return(:invalid_indata)
      expect { scrobbling.possible? }.to raise_error(Spotify::Error)
    end
  end

  describe "#reset" do
    it "sets the local scrobbling state to use the global state"
  end
end
