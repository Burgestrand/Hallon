# coding: utf-8
describe Hallon::Observable do
  let(:klass) do
    Class.new do
      include Hallon::Observable

      def fire!(name, *args, &block)
        callback_for(name).call(*args, &block)
      end

      protected

      def testing_callback
        trigger(:testing)
      end

      def testing_string_callback
        trigger("testing_string")
      end

      def testing_symbol_callback
        trigger(:testing_symbol)
      end

      def testing_arguments_callback(x, y)
        trigger(:testing_arguments, x * 2, y * 4)
      end
    end
  end

  subject { klass.new }

  describe "#on" do
    it "should take both a symbol and a string" do
      string = false
      symbol = false

      subject.on("testing_string") { string = true }
      subject.on(:testing_symbol) { symbol = true }

      subject.fire!(:testing_string)
      subject.fire!("testing_symbol")

      string.should be_true
      symbol.should be_true
    end

    it "should receive the callback after it’s been processed" do
      x = nil
      y = nil

      subject.on(:testing_arguments) do |a, b|
        x = a
        y = b
      end

      subject.fire!(:testing_arguments, 10, "Hi")

      x.should eq 20
      y.should eq "HiHiHiHi"
    end

    it "should replace the previous callback if there was one" do
      x = 0

      subject.on(:testing) { x += 1 }
      subject.fire!(:testing)
      x.should eq 1

      subject.on(:testing) { x -= 1 }
      subject.fire!(:testing)
      x.should eq 0
    end

    it "should raise an error trying to bind to a non-existing callback" do
      expect { subject.on("nonexisting") {} }.to raise_error(NameError)
    end

    it "should raise an error when not given a block" do
      expect { subject.on(:testing) }.to raise_error(ArgumentError)
    end
  end

  describe "#trigger" do
    it "should always append self to the arguments" do
      block = proc {}
      subject.on(:testing, &block)
      block.should_receive(:call).with(subject)
      subject.send(:trigger, :testing)
    end
  end

  describe "#protecting_handlers" do
    it "should call the given block, returning the result" do
      was_called = false
      subject.protecting_handlers { was_called = true }.should be_true
      was_called.should be_true
    end

    it "should restore previous handlers on return" do
      subject.on(:testing) { "before" }

      subject.protecting_handlers do
        subject.fire!(:testing).should eq "before"
        subject.on(:testing) { "after" }
        subject.fire!(:testing).should eq "after"
      end

      subject.fire!(:testing).should eq "before"
    end
  end
end
