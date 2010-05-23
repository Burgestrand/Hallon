require 'hallon'

describe Hallon do
  it "should be up to date" do
    Hallon::API_VERSION.should == 4
  end
end