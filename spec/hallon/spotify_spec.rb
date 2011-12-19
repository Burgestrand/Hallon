describe Spotify do
  describe "a wrapped function" do
    let(:null_pointer) { FFI::Pointer.new(0) }
    subject do
      Spotify.should_receive(:session_user).and_return(null_pointer)
      Spotify.session_user!(session)
    end

    it "should return a Spotify::Pointer" do
      subject.should be_a Spotify::Pointer
    end

    it "should not add ref when the result is nil" do
      Spotify.should_not_receive(:user_add_ref)
      subject.should be_null
    end
  end

  describe Spotify::Pointer do
    describe ".typechecks?" do
      it "should return false for non-spotify pointers" do
        Spotify::Pointer.typechecks?(double(type: :artist), :artist).should be_false
      end

      it "should be false for pointers of another type if type is given" do
        Spotify::Pointer.typechecks?(mock_album, :artist).should be_false
      end

      it "should be true for a pointer of the correct type" do
        Spotify::Pointer.typechecks?(mock_album, :album).should be_true
      end
    end

    describe "garbage collection" do
      let(:my_pointer) { FFI::Pointer.new(1) }

      it "should work" do
        # GC tests are a bit funky, but as long as we garbage_release at least once, then
        # we can assume our GC works properly, but up the stakes just for the sake of it
        Spotify.should_receive(:garbage_release).with(my_pointer).at_least(3).times
        5.times { Spotify::Pointer.new(my_pointer, :garbage, false) }
        5.times { GC.start; sleep 0.01 }
      end
    end
  end

  describe Spotify::CallbackStruct do
    subject { Spotify::SessionCallbacks.new }
    it { should be_a Spotify::CallbackStruct }

    it "should raise an error if given a callback of the wrong arity" do
      callback = lambda { |x| }
      expect { subject[:logged_in] = callback }.to raise_error(ArgumentError, /takes 2 arguments/)
    end
  end
end
