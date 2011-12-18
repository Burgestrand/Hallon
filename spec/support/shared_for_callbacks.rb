RSpec.configure do
  def specification_for_callback(name, *args, &block)
    describe("##{name}_callback", *args) do
      let(:subject_callback) do
        subject.class.send(:callback_for, name)
      end

      let(:klass) do
        observable_class = described_class
        pointer_address  = input[0].address

        Class.new do
          extend observable_class

          attr_reader :callbacks

          def initialize
            subscribe_for_callbacks do |callbacks|
              @callbacks = callbacks
            end
          end

          define_method(:pointer) do
            FFI::Pointer.new(pointer_address)
          end
        end
      end

      subject { klass.new }

      instance_eval(&block)

      it "should trigger #{name} with the proper arguments" do
        block = proc {}

        subject.on(name, &block)
        block.should_receive(:call) do |*args|
          output.each_with_index do |e, i|
            args[i].should === e
          end
          nil
        end

        subject_callback.call(*input)
      end

      # this is not needed for struct members when creating the
      # callback struct trough .create, as that method will make
      # sure the methods have the correct arity
      # (also, we can’t find the struct callback arity in any nice way)
      it "should have the correct arity" do
        fn = Spotify.find_type(type)
        subject_callback.arity.should eq fn.param_types.size
      end if method_defined?(:type)
    end
  end
end
