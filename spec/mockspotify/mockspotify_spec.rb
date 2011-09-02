describe Spotify::Mock do
  it "should have injected itself into Spotify's ancestor chain" do
    ancestors = (class << Spotify; self; end).ancestors
    mock_index = ancestors.index(Spotify::Mock)
    ffi_index  = ancestors.index(FFI::Library)

    mock_index.should < ffi_index # [Mock, FFI, BasicObject]
  end

  describe "hextoa" do
    it "should convert a hexidecimal string properly" do
      Spotify.attach_function :hextoa, [:string, :int], :string
      Spotify.hextoa("3A3A", 4).should eq "::"
    end
  end

  describe "atohex" do
    it "should convert a byte string to a hexadecimal string" do
      Spotify.attach_function :atohex, [:buffer_out, :buffer_in, :int], :void

      FFI::Buffer.alloc_out(8) do |b|
        Spotify.atohex(b, "\x3A\x3A\x0F\xF1", b.size)
        b.get_string(0, b.size).should eq "3a3a0ff1"
      end
    end
  end
end
