describe Hallon::Linkable do
  it "should define the #from_link method" do
    klass = Class.new
    klass.should_not respond_to :from_link

    klass.instance_exec do
      extend Hallon::Linkable
      from_link :foobar
    end

    klass.should respond_to :from_link
  end

  describe "#from_link" do
    it "should call the given block if necessary" do
      called = false
      klass = Class.new

      klass.instance_exec do
        extend Hallon::Linkable
        from_link(nil) { called = true }
      end

      klass.from_link("spotify:search:whatever")
      called.should eq true
    end

    it "should pass extra parameters to the defining block" do
      klass = Class.new

      link = mock
      link.stub(:pointer)
      Hallon::Link.stub(:new => link)

      klass.instance_exec do
        extend Hallon::Linkable
        from_link(nil) { |link, *args| args }
      end

      klass.from_link("spotify:user:burgestrand", :cool, 5).should eq [:cool, 5]
    end
  end
end
