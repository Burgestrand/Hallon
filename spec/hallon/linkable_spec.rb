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
    object.should_not respond_to :from_link

    klass.instance_eval do
      from_link(:as_search)
    end

    object.should respond_to :from_link
  end

  describe "#from_link" do
    it "should call the appropriate Spotify function" do
      Spotify.should_receive(:link_as_search!).and_return(pointer)
      klass.instance_eval do
        from_link(:as_search)
      end

      object.from_link 'spotify:search:moo'
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

      expect { object.from_link 'spotify:search:whatever' }.to change { called }
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

      object.from_link("spotify:search:burgestrand", :cool, 5)
      passed_args.should eq [:cool, 5]
    end
  end
end
