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

  before(:each) { Spotify.stub(:link_as_search) }

  it "should define the #from_link method" do
    object.should_not respond_to :from_link
    klass.from_link(:as_search)
    object.should respond_to :from_link
  end

  describe "#from_link" do
    it "should call the appropriate Spotify function" do
      Spotify.should_receive(:link_as_search).and_return(pointer)

      klass.from_link(:as_search)
      object.from_link 'spotify:search:moo'
    end

    it "should call the given block if necessary" do
      Spotify.should_not_receive(:link_as_search)

      called = false
      klass.from_link(:as_search) { called = true and pointer }
      expect { object.from_link 'spotify:search:whatever' }.to change { called }
    end

    it "should pass extra parameters to the defining block" do
      passed_args = nil
      klass.from_link(:search) { |link, *args| passed_args = args and pointer }
      object.from_link("spotify:search:burgestrand", :cool, 5)
      passed_args.should eq [:cool, 5]
    end

    it "should fail, given a null pointer" do
      klass.from_link(:as_search)
      expect { object.from_link FFI::Pointer.new(0) }.to raise_error(Hallon::Error)
    end
  end
end
