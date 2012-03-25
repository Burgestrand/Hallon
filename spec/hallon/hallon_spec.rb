# coding: utf-8
describe Hallon do
  describe "VERSION" do
    specify { Hallon::VERSION.should be_a String }
  end

  describe "API_VERSION" do
    specify { Hallon::API_VERSION.should == 10 }
  end

  describe "API_BUILD" do
    specify { Hallon::API_BUILD.should be_a String }
  end

  describe "URI" do
    example_uris.keys.each do |uri|
      specify(uri) { Hallon::URI.match(uri)[0].should eq uri }
    end
  end

  describe "#load_timeout" do
    it "should raise an error given a negative timeout" do
      expect { Hallon.load_timeout = -1 }.to raise_error(ArgumentError)
    end

    it "should allow setting and retrieving the value" do
      expect { Hallon.load_timeout = 0.2 }.
        to change { Hallon.load_timeout }
    end
  end
end
