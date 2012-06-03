describe Hallon::Base do
  let(:klass) do
    Class.new(Hallon::Base) do
      def initialize(pointer)
        @pointer = to_pointer(pointer, :base) { |x| x }
      end
    end
  end

  let(:base_pointer) do
    Spotify.stub(:base_add_ref => nil, :base_release => nil)
    Spotify::Pointer.new(a_pointer, :base, true)
  end

  describe "#to_pointer" do
    it "should not accept raw FFI pointers" do
      expect { klass.new(a_pointer) }.to raise_error(TypeError)
    end

    it "should raise an error if given an invalid pointer type" do
      expect { klass.new(mock_album) }.to raise_error(TypeError)
    end
  end

  describe ".from" do
    it "should return a new object if given pointer is not null" do
      klass.from(base_pointer).should_not be_nil
    end

    it "should return nil if given pointer is null" do
      klass.from(null_pointer).should be_nil
    end

    it "should return nil if given object is nil" do
      klass.from(nil).should be_nil
    end
  end

  describe "#==" do
    it "should compare the pointers if applicable" do
      one = klass.new(base_pointer)
      two = klass.new(base_pointer)

      one.should eq two
    end

    it "should fall back to default object comparison" do
      one = klass.new(base_pointer)
      two = klass.new(base_pointer)
      two.stub(:respond_to?).and_return(false)

      one.should_not eq two
    end
  end
end
