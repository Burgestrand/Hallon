RSpec.configure do
  def specification_for_callback(name, *args, &block)
    describe("##{name}_callback", *args) do
      subject do
        o = Object.new
        o.extend(described_class)
        o
      end

      instance_eval(&block)

      it "should trigger #{name} with the proper arguments" do
        block = proc {}

        subject.on(name, &block)
        block.should_receive(:call).with(*output)

        subject.callback_for(name).call(*input)
      end

      # this is not needed for struct members when creating the
      # callback struct trough .create, as that method will make
      # sure the methods have the correct arity
      # (also, we can’t find the struct callback arity in any nice way)
      it "should have the correct arity" do
        fn = Spotify.find_type(type)
        subject.callback_for(name).arity.should eq fn.param_types.size
      end if method_defined?(:type)
    end
  end
end
