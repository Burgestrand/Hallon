describe Hallon::Linkable do
  it "should define the #convert method" do
    klass = Class.new
    klass.should_not respond_to :convert

    klass.instance_exec do
      extend Hallon::Linkable
      link_converter :foobar
    end

    klass.should respond_to :convert
  end

  specify "#convert should call the given block if necessary" do
    called = false
    klass = Class.new

    klass.instance_exec do
      extend Hallon::Linkable
      link_converter(nil) { called = true }
    end

    klass.convert("spotify:search:whatever")
    called.should eq true
  end
end
