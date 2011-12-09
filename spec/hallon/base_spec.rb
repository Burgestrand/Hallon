describe Hallon::Base do
  let(:klass) do
    Class.new(Hallon::Base) do
      def initialize(pointer)
        @pointer = pointer
      end
    end
  end

  describe ".from" do
    it "should return a new object if given pointer is not null" do
      a_pointer.should_receive(:null?).and_return(false)
      klass.from(a_pointer).should_not be_nil
    end

    it "should return nil if given pointer is null" do
      a_pointer.should_receive(:null?).and_return(true)
      klass.from(a_pointer).should be_nil
    end
  end

  describe "#==" do
    it "should compare the pointers if applicable" do
      one = klass.new(a_pointer)
      two = klass.new(a_pointer)

      one.should eq two
    end

    it "should fall back to default object comparison" do
      one = klass.new(a_pointer)
      two = klass.new(a_pointer)
      two.stub(:respond_to?).and_return(false)

      one.should_not eq two
    end
  end
end
