# coding: utf-8
require 'spotify'
require 'hallon/ext/spotify'
require 'hallon/ext/ffi'

require 'hallon/observable'
require 'hallon/linkable'
require 'hallon/loadable'

require 'hallon/version'
require 'hallon/error'
require 'hallon/base'
require 'hallon/enumerator'
require 'hallon/audio_queue'
require 'hallon/blob'
require 'hallon/scrobbler'

require 'hallon/observable/album_browse'
require 'hallon/observable/artist_browse'
require 'hallon/observable/image'
require 'hallon/observable/playlist_container'
require 'hallon/observable/playlist'
require 'hallon/observable/post'
require 'hallon/observable/session'
require 'hallon/observable/search'
require 'hallon/observable/toplist'
require 'hallon/observable/player'

require 'hallon/session'
require 'hallon/link'
require 'hallon/user'
require 'hallon/image'
require 'hallon/track'
require 'hallon/album'
require 'hallon/artist'
require 'hallon/toplist'
require 'hallon/playlist'
require 'hallon/playlist_container'
require 'hallon/album_browse'
require 'hallon/artist_browse'
require 'hallon/player'
require 'hallon/search'

# Why is this not the default in Ruby?
Thread.abort_on_exception = true

# The Hallon module wraps around all Hallon objects to avoid polluting
# the global namespace. To start using Hallon, you most likely want to
# be looking for the documentation on {Hallon::Session}.
module Hallon
  # @see Spotify::API_VERSION
  API_VERSION = Spotify::API_VERSION.to_i

  # A regex that matches all Spotify URIs
  #
  # @example
  #   Hallon::URI === "spotify:user:burgestrand" # => true
  URI = /(spotify:(?:
    (?:artist|album|user:[^:]+:playlist):[a-zA-Z0-9]{22}
    |track:[a-zA-Z0-9]{22}(?:\#\d{1,2}:\d{1,2})?
    |user:[^:]+(?::starred)?
    |search:(?:[-\w$\.+!*'(),]+|%[a-fA-F0-9]{2})+
    |image:[a-fA-F0-9]{40}
    ))
  /x

  # Thrown by {Loadable#load} and {Playlist#upload} on failure.
  TimeoutError = Class.new(Hallon::Error)

  # Raised by Session.instance
  NoSessionError = Class.new(Hallon::Error)

  # Raised by Session#login! and Session#relogin!
  LoginError = Class.new(Hallon::Error)

  # Raised by PlaylistContainer#num_unseen_tracks_for and PlaylistContainer#unseen_tracks_for.
  # @note most likely raised because of the playlist not being in the playlist container.
  OperationFailedError = Class.new(Hallon::Error)

  class << self
    # @return [Numeric] default load timeout in seconds, used in {Loadable#load}.
    attr_reader :load_timeout

    # @param [Numeric] new_timeout default load_timeout in seconds for {Loadable#load}.
    def load_timeout=(new_timeout)
      if new_timeout < 0
        raise ArgumentError, "timeout cannot be negative"
      end

      @load_timeout = new_timeout
    end
  end

  self.load_timeout = 31.4159 # seconds
end
