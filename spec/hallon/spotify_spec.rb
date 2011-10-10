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

  describe "garbage collection" do
    let(:my_pointer) { FFI::Pointer.new(1) }

    it "should work" do
      Spotify.should_receive(:garbage_release).exactly(5).times
      5.times { Spotify::Pointer.new(my_pointer, :garbage, false) }
      5.times { GC.start; sleep 0.05 }
    end
  end
end
