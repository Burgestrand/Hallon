# coding: utf-8
require 'cgi'

describe Hallon::Search do
  let(:search) do
    Hallon::Search.new("my å utf8  query")
  end

  let(:empty_search) do
    Hallon::Search.new("")
  end

  specify { search.should be_a Hallon::Loadable }
  specify { search.should be_a Hallon::Observable }

  it_should_behave_like "a Linkable object" do
    let(:spotify_uri) { "spotify:search:my+%C3%A5+utf8+%EF%A3%BF+query" }
    let(:custom_object) { "http://open.spotify.com/search/my+%C3%A5+utf8+%EF%A3%BF+query" }
    let(:described_class) { Hallon::Search }
  end

  describe ".new" do
    it "should have some sane defaults" do
      Spotify.should_receive(:search_create).with(session.pointer, "my å utf8  query", 0, 25, 0, 25, 0, 25, 0, 25, :standard, anything, anything).and_return(mock_search)
      Hallon::Search.new("my å utf8  query")
    end

    it "should allow you to customize the defaults" do
      Spotify.should_receive(:search_create).with(session.pointer, "my å utf8  query", 1, 2, 3, 4, 5, 6, 7, 8, :suggest, anything, anything).and_return(mock_search)
      my_params = {
        :tracks_offset  => 1,
        :tracks         => 2,
        :albums_offset  => 3,
        :albums         => 4,
        :artists_offset => 5,
        :artists        => 6,
        :playlists_offset => 7,
        :playlists      => 8,
        :type           => :suggest
      }

      Hallon::Search.new("my å utf8  query", my_params)
    end

    it "should raise an error given an invalid search type" do
      expect { Hallon::Search.new("my å utf8  query", type: :hulabandola) }.to raise_error(ArgumentError)
    end

    it "should raise an error if the search failed" do
      Spotify.should_receive(:search_create).and_return(null_pointer)
      expect { Hallon::Search.new("omgwtfbbq") }.to raise_error(/search (.*?) failed/)
    end
  end

  describe "#loaded?" do
    it "returns true if the search is complete" do
      search.should be_loaded
    end
  end

  describe "#status" do
    it "returns the status of the search" do
      search.status.should eq :ok
    end
  end

  describe "#query" do
    it "returns the search query" do
      search.query.should eq "my å utf8  query"
    end
  end

  describe "#did_you_mean" do
    it "returns a suggestion for what the query might have intended to be" do
      search.did_you_mean.should eq "another thing"
    end

    it "returns an empty string if there is no suggestion available" do
      empty_search.did_you_mean.should be_empty
    end
  end

  describe "#tracks" do
    it "returns an enumerator of the search’s track" do
      search.tracks.to_a.should eq instantiate(Hallon::Track, mock_track, mock_track_two)
    end

    it "returns an empty enumerator if there are no search results" do
      empty_search.tracks.should be_empty
    end

    describe ".total" do
      it "returns the total number of track search results" do
        search.tracks.total.should eq 1337
      end

      it "returns zero if there are no search results whatsoever" do
        empty_search.tracks.total.should eq 0
      end
    end
  end

  describe "#albums" do
    it "returns an enumerator of the search’s albums" do
      search.albums.to_a.should eq instantiate(Hallon::Album, mock_album)
    end

    it "returns an empty enumerator if there are no search results" do
      empty_search.albums.should be_empty
    end

    describe ".total" do
      it "returns the total number of album search results" do
        search.albums.total.should eq 42
      end

      it "returns zero if there are no search results whatsoever" do
        empty_search.albums.total.should eq 0
      end
    end
  end

  describe "#artists" do
    it "returns an enumerator of the search’s artists" do
      search.artists.to_a.should eq instantiate(Hallon::Artist, mock_artist, mock_artist_two)
    end

    it "returns an empty enumerator if there are no search results" do
      empty_search.artists.should be_empty
    end

    describe ".total" do
      it "returns the total number of artist search results" do
        search.artists.total.should eq 81104
      end

      it "returns zero if there are no search results whatsoever" do
        empty_search.artists.total.should eq 0
      end
    end
  end

  describe "#playlist_names" do
    it "returns an enumerator of the search’s playlist names" do
      search.playlist_names.to_a.should eq %w(Dunderlist)
    end

    it "returns an empty enumerator of there are no search results" do
      empty_search.playlist_names.should be_empty
    end

    describe ".total" do
      it "returns the total number of search results" do
        search.playlist_names.total.should eq 462
      end

      it "returns zero if there are no search results whatsoever" do
        empty_search.playlist_names.total.should eq 0
      end
    end
  end

  describe "#playlist_uris" do
    it "returns an enumerator of the search’s playlist uris" do
      search.playlist_uris.to_a.should eq %w(spotify:user:burgestrand:playlist:megaplaylist)
    end

    it "returns an empty enumerator of there are no search results" do
      empty_search.playlist_uris.should be_empty
    end

    describe ".total" do
      it "returns the total number of search results" do
        search.playlist_uris.total.should eq 462
      end

      it "returns zero if there are no search results whatsoever" do
        empty_search.playlist_uris.total.should eq 0
      end
    end
  end

  describe "#playlist_image_uris" do
    it "returns an enumerator of the search’s playlist image uris" do
      search.playlist_image_uris.to_a.should eq %w(spotify:image:3ad93423add99766e02d563605c6e76ed2b0e400)
    end

    it "returns an empty enumerator of there are no search results" do
      empty_search.playlist_image_uris.should be_empty
    end

    describe ".total" do
      it "returns the total number of search results" do
        search.playlist_image_uris.total.should eq 462
      end

      it "returns zero if there are no search results whatsoever" do
        empty_search.playlist_image_uris.total.should eq 0
      end
    end
  end

  describe "#playlists" do
    it "returns an enumerator of the search’s playlists" do
      search.playlists.to_a.should eq instantiate(Hallon::Playlist, mock_playlist_two)
    end

    it "returns an empty enumerator of there are no search results" do
      empty_search.playlists.should be_empty
    end

    describe ".total" do
      it "returns the total number of search results" do
        search.playlists.total.should eq 462
      end

      it "returns zero if there are no search results whatsoever" do
        empty_search.playlists.total.should eq 0
      end
    end
  end

  describe "#playlist_images" do
    it "returns an enumerator of the search’s playlist images" do
      search.playlist_images.to_a.should eq instantiate(Hallon::Image, mock_image)
    end

    it "returns an empty enumerator of there are no search results" do
      empty_search.playlist_images.should be_empty
    end

    describe ".total" do
      it "returns the total number of search results" do
        search.playlist_images.total.should eq 462
      end

      it "returns zero if there are no search results whatsoever" do
        empty_search.playlist_images.total.should eq 0
      end
    end
  end

  describe "#to_link" do
    it "contains the search query" do
      search.to_link.should eq Hallon::Link.new("spotify:search:#{CGI.escape(search.query)}")
    end
  end
end
