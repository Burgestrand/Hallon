require 'hallon'

describe Hallon do
  it "should be up to date" do
    Hallon::API_VERSION.should == 4
  end

  describe Hallon::Error do
    it "should translate error codes" do
      Hallon::Error.message(1).should == 'Invalid library version'
    end
  end
end