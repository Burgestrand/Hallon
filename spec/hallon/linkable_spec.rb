describe Hallon::Linkable do
  let(:klass) do
    klass = Class.new
    klass.instance_eval do
      extend Hallon::Linkable
    end
    klass
  end

  let(:object) { klass.new }
  let(:pointer) { FFI::Pointer.new(1) }

  before(:each) { Spotify.stub(:link_as_search!) }

  it "should define the #from_link method" do
    object.respond_to?(:from_link, true).should be_false

    klass.instance_eval do
      from_link(:as_search)
    end

    object.respond_to?(:from_link, true).should be_true
  end

  describe "#to_link" do
    it "should return nil if link creation failed" do
      Spotify.should_receive(:link_create_from_user).and_return(null_pointer)

      klass.instance_eval do
        to_link(:from_user)
        attr_reader :pointer
      end

      object.to_link.should be_nil
    end
  end

  describe "#from_link" do
    it "should call the appropriate Spotify function" do
      Spotify.should_receive(:link_as_search!).and_return(pointer)

      klass.instance_eval do
        from_link(:as_search)
      end

      object.send(:from_link, 'spotify:search:moo')
    end

    it "should call the given block if necessary" do
      Spotify.should_not_receive(:link_as_search!)

      called  = false
      pointer = double(:null? => false)

      klass.instance_eval do
        from_link(:as_search) do
          called = true
          pointer
        end
      end

      expect { object.send(:from_link, 'spotify:search:whatever') }.to change { called }
    end

    it "should pass extra parameters to the defining block" do
      passed_args = nil

      pointer = double(:null? => false)

      klass.instance_eval do
        from_link(:search) do |link, *args|
          passed_args = args
          pointer
        end
      end

      object.send(:from_link, "spotify:search:burgestrand", :cool, 5)
      passed_args.should eq [:cool, 5]
    end
  end
end
