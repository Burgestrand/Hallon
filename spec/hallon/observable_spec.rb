describe Hallon::Observable do
  subject do
    Class.new { include Hallon::Observable }.new
  end

  describe "instance methods" do
    it { should respond_to :on }
    it { should respond_to :trigger }
  end

  describe "#on" do
    it "should allow defining one handler for multiple events" do
      subject.on(:a, :b, :c) do |event, *args|
        "yay"
      end

      subject.trigger(:a).should eq "yay"
      subject.trigger(:b).should eq "yay"
      subject.trigger(:c).should eq "yay"
    end

    specify "a multi-declared handler should know its name" do
      subject.on(:a, :b) { |event, *args| event }
      subject.trigger(:a).should eq :a
      subject.trigger(:b).should eq :b
    end

    specify "a single-declared handler should not know its name" do
      subject.on(:a) { |event, *args| event }
      subject.trigger(:a).should eq nil
    end

    it "should convert the event to a symbol" do
      subject.on("a") { raise "hell" }
      expect { subject.trigger(:a) }.to raise_error("hell")
    end
  end

  describe "#trigger and #on" do
    it "should define and call event handlers" do
      called = false
      subject.on(:a) { called = true }
      subject.trigger(:a)
      called.should be_true
    end

    it "should pass any arguments to handlers" do
      passed_args = []
      subject.on(:a) { |*args| passed_args = args }
      subject.trigger(:a, :b, :c)
      passed_args.should eq [:b, :c]
    end

    it "should do nothing when there are no handlers" do
      subject.trigger(:this_event_does_not_exist).should be_nil
    end

    context "multiple handlers" do
      it "should call all handlers in order" do
        triggered = []
        subject.on(:a) { triggered << :a }
        subject.on(:a) { triggered << :b }
        subject.trigger(:a)
        triggered.should eq [:a, :b]
      end

      it "should return the last-returned value" do
        subject.on(:a) { :first }
        subject.on(:a) { :second }
        subject.trigger(:a).should eq :second
      end

      it "should allow execution to be aborted" do
        subject.on(:a) { throw :return, :first }
        subject.on(:b) { :second }
        subject.trigger(:a).should eq :first
      end
    end
  end

  describe "#protecting_handlers" do
    it "should call the given block, returning the result" do
      was_called = false
      subject.protecting_handlers { was_called = true }.should be_true
      was_called.should be_true
    end

    it "should restore previous handlers on return" do
      subject.on(:protected) { "before" }

      subject.protecting_handlers do
        subject.trigger(:protected).should eq "before"
        subject.on(:protected) { "after" }
        subject.trigger(:protected).should eq "after"
      end

      subject.trigger(:protected).should eq "before"
    end

    it "should still allow #trigger to work on non-defined events" do
      subject.protecting_handlers {}
      expect { subject.trigger(:does_not_exist) }.to_not raise_error
    end
  end

end
