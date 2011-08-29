# coding: utf-8
describe Hallon::Artist do
  subject { Hallon::Artist.new(mock_artist) }

  its(:name) { should eq "Jem" }
  it { should be_loaded }
end
