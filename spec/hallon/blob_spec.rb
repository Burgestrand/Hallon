describe Hallon::Blob do
  it "is infectious" do
    Hallon::Blob("string").should be_a Hallon::Blob
    Hallon::Blob("string").should be_a String
  end
end
