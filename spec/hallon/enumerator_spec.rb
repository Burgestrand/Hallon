# coding: utf-8
describe Hallon::Enumerator do
  def enumerator(items)
    Spotify.stub(:enumerator_size => items)
    Spotify.stub(:enumerator_item).and_return { |_, i| alphabet[i] }

    klass = Class.new(Hallon::Enumerator) do
      size :enumerator_size
      item :enumerator_item
    end

    struct = OpenStruct.new(:pointer => nil)
    klass.new(struct)
  end

  # our subject
  let(:enum) { enumerator(5) }

  # this is a proc so we can pass it to #and_return
  # we can still access elements with #[] though, ain’t that nice?
  let(:alphabet) do
    proc { |x| %w[a b c d e][x] }
  end

  it "should be an enumerable" do
    enum.should respond_to :each
    enum.should be_an Enumerable
  end

  describe "#each" do
    it "should yield items from the collection" do
      enum.each_with_index { |x, i| x.should eq alphabet[i] }
    end

    it "should stop enumerating if the size shrinks below current index during iteration" do
      iterations = 0

      enum.map do |x|
        enum.should_receive(:size).and_return(0)
        iterations += 1
      end

      iterations.should eq 1
    end
  end

  describe "#size" do
    it "should return the given size" do
      enum.size.should eq 5
    end
  end

  describe "#[]" do
    it "should return nil if #[x] is not within the enumerators’ size (no matter if the value exists or not)" do
      enum.should_receive(:size).and_return(1)
      enum[1].should be_nil
    end

    it "should support #[x] within range" do
      alphabet.should_receive(:[]).with(1).and_return(&alphabet)

      enum[1].should eq "b"
    end

    it "should support negative #[x] within range" do
      alphabet.should_receive(:[]).with(4).and_return(&alphabet)

      enum[-1].should eq "e"
    end

    it "should return nil for #[x] outside range" do
      alphabet.should_not_receive(:get)

      enum[6].should be_nil
    end

    it "should return nil for #[-x] outside range" do
      alphabet.should_not_receive(:get)

      enum[-6].should be_nil
    end

    it "should return a slice of elements for #[x, y]" do
      alphabet.should_receive(:[]).with(1).and_return(&alphabet)
      alphabet.should_receive(:[]).with(2).and_return(&alphabet)

      enum[1, 2].should eq %w[b c]
    end

    it "should return elements for an inclusive range of #[x..y]" do
      alphabet.should_receive(:[]).with(1).and_return(&alphabet)
      alphabet.should_receive(:[]).with(2).and_return(&alphabet)
      alphabet.should_receive(:[]).with(3).and_return(&alphabet)

      enum[1..3].should eq %w[b c d]
    end

    it "should return return only existing elements for partly inclusive range of #[x..y]" do
      alphabet.should_receive(:[]).with(4).and_return(&alphabet)

      enum[4..7].should eq %w[e]
    end

    it "should return nil for a completely outside range of #[x..y]" do
      alphabet.should_not_receive(:[])

      enum[6..10].should eq nil
    end

    it "should return the items for #[-x, y]" do
      alphabet.should_receive(:[]).with(2).and_return(&alphabet)
      alphabet.should_receive(:[]).with(3).and_return(&alphabet)
      alphabet.should_receive(:[]).with(4).and_return(&alphabet)

      enum[-3, 3].should eq %w[c d e]
    end

    it "should slice between items by #[x, y]" do
      alphabet.should_not_receive(:[])

      enum[5, 1].should eq []
    end

    it "should slice between items by #[x..y]" do
      alphabet.should_not_receive(:[])

      enum[5..10].should eq []
    end
  end
end
