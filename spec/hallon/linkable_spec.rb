describe Hallon::Linkable do
  it "should define the #convert method" do
    klass = Class.new
    klass.should_not respond_to :convert

    klass.instance_exec do
      include Hallon::Linkable
      link_converter :foobar
    end

    klass.should respond_to :convert
  end

  describe "#convert" do
    it "should call the given block if necessary" do
      called = false
      klass = Class.new

      klass.instance_exec do
        include Hallon::Linkable
        link_converter(nil) { called = true }
      end

      klass.convert("spotify:search:whatever")
      called.should eq true
    end

    it "should pass extra parameters to the defining block" do
      klass = Class.new

      link = mock
      link.stub(:pointer)
      Hallon::Link.stub(:new => link)

      klass.instance_exec do
        include Hallon::Linkable
        link_converter(nil) { |link, *args| args }
      end

      klass.convert("spotify:user:burgestrand", :cool, 5).should eq [:cool, 5]
    end
  end
end
