# coding: utf-8
describe Hallon::Image, :logged_in => true do
  context "created from a Spotify URI" do
    before(:all) do
      @uri   = "spotify:image:3ad93423add99766e02d563605c6e76ed2b0e450"
      @image = Hallon::Image.new @uri
      @image.status.should eq :is_loading
      session.process_events_on { @image.loaded? }
    end

    subject { @image }

    its(:status) { should be :ok }
    its(:format) { should be :jpeg }

    specify "its #id should match its’ spotify uri" do
      @uri.should match @image.id
    end

    describe "#data" do
      it "should correspond to the fixture image" do
        image_path = File.expand_path('./../../support/image_fixture.jpg', __FILE__)
        @image.data.should eq File.read(image_path, :encoding => 'binary')
      end

      it "should have a binary encoding" do
        @image.data.encoding.name.should eq 'ASCII-8BIT'
      end
    end
  end

  describe "callbacks" do
    it "should trigger :load when loaded" do
      uri = "spotify:image:c78f091482e555bd2ffacfcd9cbdc0714b221663"
      image = Hallon::Image.new(uri)
      image.should_not be_loaded
      image.should_receive(:trigger).with(:load).once

      session.process_events_on { image.loaded? }
    end
  end
end
