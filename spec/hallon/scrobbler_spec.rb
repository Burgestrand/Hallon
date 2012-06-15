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

  describe "#credentials=" do
    it "sets the credentials for the scrobbler provider" do
      Spotify.should_receive(:session_set_social_credentials).with(anything, :facebook, "Kim", "password").and_return(:ok)
      scrobbling.credentials = "Kim", "password"
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

  describe "#enabled=" do
    it "sets the local scrobbling" do
      scrobbling.should_not be_enabled
      scrobbling.enabled = true
      scrobbling.should be_enabled
      scrobbling.enabled = false
      scrobbling.should_not be_enabled
    end

    it "raises an error if setting scrobbling state fails" do
      Spotify.should_receive(:session_set_scrobbling).and_return(:invalid_indata)
      expect { scrobbling.enabled = true }.to raise_error(Spotify::Error, /INVALID_INDATA/)
    end
  end

  describe "#enabled?" do
    before do
      Spotify.should_receive(:session_is_scrobbling).and_return do |session, provider, buffer|
        buffer.write_int(Spotify.enum_value(state_symbol))
      end
    end

    context "if the state is locally enabled" do
      let(:state_symbol) { :local_enabled }

      it "returns true" do
        scrobbling.should be_enabled
      end
    end

    context "if the state is locally disabled" do
      let(:state_symbol) { :local_disabled }

      it "returns false" do
        scrobbling.should_not be_enabled
      end
    end

    context "if the state is globally enabled" do
      let(:state_symbol) { :global_enabled }

      it "returns true" do
        scrobbling.should be_enabled
      end
    end

    context "if the state is globally disabled" do
      let(:state_symbol) { :global_disabled }

      it "returns false" do
        scrobbling.should_not be_enabled
      end
    end
  end

  describe "#reset" do
    def state(scrobbler)
      session = scrobbling.send(:session)
      state   = nil
      FFI::Buffer.alloc_out(:int) do |buffer|
        Spotify.session_is_scrobbling!(session.pointer, scrobbling.provider, buffer)
        state = buffer.read_int
      end
      Spotify.enum_type(:scrobbling_state)[state]
    end

    it "sets the local scrobbling state to use the global state" do
      scrobbling.enabled = true
      state(scrobbling).should eq :local_enabled
      scrobbling.reset
      state(scrobbling).should eq :global_enabled
    end
  end
end
