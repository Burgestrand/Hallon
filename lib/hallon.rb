# coding: utf-8
require 'spotify'
require 'hallon/ext/spotify'
require 'hallon/ext/ffi'

require 'hallon/observable'
require 'hallon/linkable'

require 'hallon/version'
require 'hallon/error'
require 'hallon/base'
require 'hallon/queue'
require 'hallon/enumerator'

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

# The Hallon module wraps around all Hallon objects to avoid polluting
# the global namespace. To start using Hallon, you most likely want to
# be looking for the documentation on {Hallon::Session}.
module Hallon
  # @see Spotify::API_VERSION
  API_VERSION = Spotify::API_VERSION

  # Spotify API build.
  #
  # @see Spotify#api_build
  API_BUILD = Spotify.build_id

  # A regex that matches all Spotify URIs
  #
  # @example
  #   Hallon::URI === "spotify:user:burgestrand" # => true
  URI = /(spotify:(?:
    (?:artist|album|track|user:[^:]+:playlist):[a-fA-F0-9]+
    |user:[^:]+
    |search:(?:[-\w$\.+!*'(),]+|%[a-fA-F0-9]{2})+
    |image:[a-fA-F0-9]{40}
    ))
  /x
end
