# coding: utf-8
describe Hallon::Image do
  around(:each) { |test| mock_session(&test) }

  describe "an image instance" do
    subject { image }

    let(:image) { Hallon::Image.new(mock_image) }

    it { should be_loaded }
    its(:status) { should be :ok }
    its(:format) { should be :jpeg }

    describe "id" do
      specify("in hex") { subject.id.should eq mock_image_hex }
      specify("raw") { subject.id(true).should eq mock_image_id }
    end

    describe "#data" do
      subject { image.data }

      it "should correspond to the fixture image" do
        should eq File.open(fixture_image_path, 'r:binary', &:read)
      end

      it "should have a binary encoding" do
        pending "ruby 1.8 does not support String#encoding" unless subject.respond_to?(:encoding)
        subject.encoding.name.should eq 'ASCII-8BIT'
      end
    end

    describe "#to_link" do
      it "should retrieve the Spotify URI" do
        image.to_link.should eq Hallon::Link.new("spotify:image:#{image.id}")
      end
    end
  end

  context "created from an url" do
    subject { Hallon::Image.new("http://open.spotify.com/image/c78f091482e555bd2ffacfcd9cbdc0714b221663") }
    its(:id) { should eq "c78f091482e555bd2ffacfcd9cbdc0714b221663" }
  end

  context "created from an uri" do
    subject { Hallon::Image.new("spotify:image:c78f091482e555bd2ffacfcd9cbdc0714b221663") }
    its(:id) { should eq "c78f091482e555bd2ffacfcd9cbdc0714b221663" }
  end

  context "created from an id" do
    subject { Hallon::Image.new(mock_image_id) }
    its(:id) { should eq mock_image_hex }
  end

  context "created from a link" do
    subject { Hallon::Image.new(Hallon::Link.new("spotify:image:c78f091482e555bd2ffacfcd9cbdc0714b221663")) }
    its(:id) { should eq "c78f091482e555bd2ffacfcd9cbdc0714b221663" }
  end

  describe "callbacks" do
    it "should trigger :load when loaded", :pending => true do
      uri = "spotify:image:c78f091482e555bd2ffacfcd9cbdc0714b221663"
      image = Hallon::Image.new(uri)
      image.should_not be_loaded
      image.should_receive(:trigger).with(:load).once

      session.process_events_on { image.loaded? }
    end
  end
end
