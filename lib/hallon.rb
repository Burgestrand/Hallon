# coding: utf-8
require 'spotify'
require 'hallon/ext/spotify'
require 'hallon/ext/ffi'

require 'hallon/synchronizable'
require 'hallon/observable'
require 'hallon/linkable'

require 'hallon/version'
require 'hallon/error'
require 'hallon/session'
require 'hallon/link'
require 'hallon/user'
require 'hallon/image'

# The Hallon module wraps around all Hallon objects to avoid polluting
# the global namespace. To start using Hallon, you most likely want to
# be looking for the documentation on {Hallon::Session}.
module Hallon
  # @see Spotify::API_VERSION
  API_VERSION = Spotify::API_VERSION

  # A regex that matches all Spotify URIs
  #
  # @example
  #   Hallon::URI === "spotify:user:burgestrand" # => true
  URI = /(spotify:(?:
    (?:artist|album|track|user:[^:]+:playlist):[a-zA-Z0-9]+
    |user:[^:]+
    |search:(?:[-\w$\.+!*'(),]+|%[a-fA-F0-9]{2})+
    ))
  /x
end
