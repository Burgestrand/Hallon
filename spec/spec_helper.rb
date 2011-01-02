require 'hallon'
require 'rspec'

# Requires supporting files in ./support/
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

# Hallon::Session#instance requires that a Session object have not been created
# so test it here instead. This assures it is tested before anything else!
describe Hallon::Session do
  it { Hallon::Session.should_not respond_to :new }

  describe "#instance" do
    it "should require an application key" do
      expect { Hallon::Session.instance }.to raise_error(ArgumentError)
    end
  
    it "should fail on an invalid application key" do
      expect { Hallon::Session.instance('invalid') }.to raise_error(Hallon::Error)
    end
  
    it "should not spawn event handling threads on failure" do
      threads = Thread.list.length
      expect { Hallon::Session.instance('invalid') }.to raise_error(Hallon::Error)
      threads.should equal Thread.list.length
    end
  
    it "should fail on a huge user agent (> 255 characters)" do
      expect { Hallon::Session.instance(Hallon::APPKEY, :user_agent => 'a' * 300) }.
        to raise_error(ArgumentError)
    end
  end
end