describe Hallon do
  describe "libspotify version" do
    specify { Hallon::API_VERSION.should equal 6 }
  end
end