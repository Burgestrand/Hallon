# coding: utf-8
require 'cgi'

describe Hallon::Search do
  it_should_behave_like "a Linkable object" do
    let(:spotify_uri) { "spotify:search:my+%C3%A5+utf8+%EF%A3%BF+query" }
    let(:custom_object) { "http://open.spotify.com/search/my+%C3%A5+utf8+%EF%A3%BF+query" }
    let(:described_class) { stub_session(Hallon::Search) }
  end

  it { should be_a Hallon::Loadable }

  subject { search }
  let(:search) do
    mock_session { Hallon::Search.new("my å utf8  query") }
  end

  describe ".new" do
    it "should have some sane defaults" do
      Spotify.should_receive(:search_create).with(session.pointer, "my å utf8  query", 0, 25, 0, 25, 0, 25, anything, anything).and_return(mock_search)
      mock_session { Hallon::Search.new("my å utf8  query") }
    end

    it "should allow you to customize the defaults" do
      Spotify.should_receive(:search_create).with(session.pointer, "my å utf8  query", 1, 2, 3, 4, 5, 6, anything, anything).and_return(mock_search)
      my_params = {
        :tracks_offset  => 1,
        :tracks         => 2,
        :albums_offset  => 3,
        :albums         => 4,
        :artists_offset => 5,
        :artists        => 6
      }

      mock_session { Hallon::Search.new("my å utf8  query", my_params) }
    end

    it "should raise an error if the search failed" do
      Spotify.should_receive(:search_create).and_return(null_pointer)
      expect { mock_session { Hallon::Search.new("omgwtfbbq") } }.to raise_error(/search (.*?) failed/)
    end
  end

  describe ".genres" do
    subject { Hallon::Search.genres }

    it { should include :jazz }
    it { should be_a Array }
    it { should_not be_empty }
  end

  describe ".radio" do
    subject do
      Spotify.registry_add 'spotify:radio:00002200:1990-2010', mock_search
      mock_session { Hallon::Search.radio(1990..2010, :jazz, :punk) }
    end

    it "should raise an error on invalid genres" do
      Spotify.should_not_receive(:radio_search_create)
      expect { Hallon::Search.radio(1990..2010, :bogus, :jazz) }.to raise_error(ArgumentError, /bogus/)
    end

    it "should raise an error if the search failed" do
      Spotify.should_receive(:radio_search_create).and_return(null_pointer)
      expect { mock_session { Hallon::Search.radio(1990..1990) } }.to raise_error(/search failed/)
    end

    it { should be_loaded }
    its(:status) { should eq :ok }
    its('tracks.size') { should eq 2 }
    # ^ should be enough
  end

  it { should be_a Hallon::Observable }
  it { should be_loaded }
  its(:status) { should eq :ok }
  its(:query) { should eq "my å utf8  query" }
  its(:did_you_mean) { should eq "another thing" }

  its('tracks.size')  { should eq 2 }
  its('tracks.to_a')  { should eq instantiate(Hallon::Track, mock_track, mock_track_two) }
  its('tracks.total') { should eq 1337 }

  its('albums.size')  { should eq 1 }
  its('albums.to_a')  { should eq instantiate(Hallon::Album, mock_album) }
  its('albums.total') { should eq 42 }

  its('artists.size')  { should eq 2 }
  its('artists.to_a')  { should eq instantiate(Hallon::Artist, mock_artist, mock_artist_two) }
  its('artists.total') { should eq 81104 }

  its(:to_link) { should eq Hallon::Link.new("spotify:search:#{CGI.escape(search.query)}") }
end
