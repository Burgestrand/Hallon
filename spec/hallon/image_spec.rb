# coding: utf-8
describe Hallon::Image do
  has_requirement "logged in" do
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

      specify "its #data should correspond to the fixture image" do
        image_path = File.expand_path('./../../support/image_fixture.jpg', __FILE__)
        @image.data.should eq File.read(image_path, :encoding => 'binary')
      end
    end
  end
end
