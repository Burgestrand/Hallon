# coding: utf-8
require 'ostruct'

describe Hallon::Image do
  let(:image) do
    Hallon::Image.new(mock_image)
  end

  let(:empty_image) do
    Hallon::Image.new(mock_empty_image)
  end

  it_should_behave_like "a Linkable object" do
    let(:spotify_uri) { "spotify:image:#{mock_image_hex}" }
    let(:custom_object) { mock_image_hex }
    let(:described_class) { Hallon::Image }
  end

  specify { image.should be_a Hallon::Loadable }

  describe "#initialize" do
    it "can load images with invalid UTF8 image ids" do
      Hallon::Image.new("spotify:image:548957670a3e9950e87ce61dc0c188debd22b0cb").should eq empty_image
    end
  end

  describe ".sizes" do
    it "should list all sizes" do
      Hallon::Image.sizes.should eq [:normal, :small, :large]
    end
  end

  describe "#loaded?" do
    it "returns true when the image is loaded" do
      image.should be_loaded
    end
  end

  describe "#status" do
    it "returns the image’s status" do
      image.status.should eq :ok
    end
  end

  describe "#format" do
    it "returns the image’s format" do
      image.format.should eq :jpeg
    end
  end

  describe "#id" do
    it "returns the image id as a hexadecimal string" do
      image.id.should eq mock_image_hex
    end
  end

  describe "#raw_id" do
    it "returns the image id as a binary string" do
      image.raw_id.should eq mock_image_id
    end
  end

  describe "#data" do
    it "returns the image’s data" do
      image.data.should eq File.open(fixture_image_path, 'r:binary', &:read)
    end

    it "has a binary encoding" do
      image.data.encoding.name.should eq 'ASCII-8BIT'
    end

    it "returns an empty string if the image is not loaded" do
      empty_image.data.should be_empty
    end
  end

  describe "#to_link" do
    it "should retrieve the Spotify URI" do
      image.to_link.should eq Hallon::Link.new("spotify:image:#{image.id}")
    end
  end

  describe "#===" do
    it "should compare ids (but only if other is an Image)" do
      other = double
      other.should_receive(:is_a?).with(Hallon::Image).and_return(true)
      other.should_receive(:raw_id).and_return(image.raw_id)

      image.should eq other
      image.should_not eq double
    end

    it "should not call #id if other is not an image" do
      other = double
      other.should_not_receive(:raw_id)

      image.should_not eq other
    end
  end
end
