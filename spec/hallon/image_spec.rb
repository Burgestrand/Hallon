# coding: utf-8
require 'ostruct'

describe Hallon::Image do
  it_should_behave_like "a Linkable object" do
    let(:spotify_uri) { "spotify:image:#{mock_image_hex}" }
    let(:custom_object) { mock_image_hex }


    let(:described_class) do
      real_session = session
      Hallon::Image.dup.tap do |klass|
        klass.class_eval do
          define_method(:session) { real_session }
        end
      end
    end
  end

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
        subject.encoding.name.should eq 'ASCII-8BIT'
      end
    end

    describe "#to_link" do
      it "should retrieve the Spotify URI" do
        image.to_link.should eq Hallon::Link.new("spotify:image:#{image.id}")
      end
    end

    describe "#==" do
      it "should not fail given an object that does not respond to id" do
        o = Object.new
        def o.id
          raise NoMethodError
        end

        image.should_not eq o
      end
    end
  end
end
