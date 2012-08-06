describe Spotify::Mock do
  it "should have injected itself into Spotify's ancestor chain" do
    ancestors = Spotify::API.singleton_class.ancestors
    mock_index = ancestors.index(Spotify::Mock)
    ffi_index  = ancestors.index(FFI::Library)

    mock_index.should < ffi_index # [Mock, FFI, BasicObject]
  end

  describe "hextoa" do
    it "should convert a hexidecimal string properly" do
      Spotify::API.attach_function :hextoa, :hextoa, [:string, :int], :string
      Spotify.hextoa("3A3A", 4).should eq "::"
    end
  end

  describe "atohex" do
    it "should convert a byte string to a hexadecimal string" do
      Spotify::API.attach_function :atohex, :atohex, [:buffer_out, :buffer_in, :int], :void

      FFI::Buffer.alloc_out(8) do |b|
        Spotify.atohex(b, "\x3A\x3A\x0F\xF1", b.size)
        b.get_string(0, b.size).should eq "3a3a0ff1"
      end
    end
  end

  describe "unregion" do
    it "should convert an integer to the correct region" do
      Spotify::API.attach_function :unregion, :unregion, [ :int ], :string

      sweden = 21317
      Spotify.unregion(sweden).should eq "SE"
    end
  end

  describe "the registry" do
    it "should find previously added entries" do
      Spotify.mock_registry_add("i_exist", FFI::Pointer.new(1))
      Spotify.mock_registry_add("i_exist_too", FFI::Pointer.new(2))

      Spotify.mock_registry_find("i_exist").should eq FFI::Pointer.new(1)
      Spotify.mock_registry_find("i_exist_too").should eq FFI::Pointer.new(2)
    end

    it "should return nil for entries not in the registry" do
      Spotify.mock_registry_find("i_do_not_exist").should be_null
    end

    it "should be cleanable" do
      pointer = FFI::MemoryPointer.new(:uint)

      Spotify.mock_registry_add("i_exist", pointer)
      Spotify.mock_registry_find("i_exist").should_not be_null

      Spotify.mock_registry_clean
      Spotify.mock_registry_find("i_exist").should be_null

      Spotify.mock_registry_add("i_exist", pointer)
      Spotify.mock_registry_find("i_exist").should_not be_null
    end
  end
end
