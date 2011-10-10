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
end
