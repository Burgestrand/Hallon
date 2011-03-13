# coding: utf-8
require 'hallon_ext'
require 'hallon/error'
require 'hallon/version'

require 'hallon/base'
require 'hallon/session'
require 'hallon/link'

# The Hallon module wraps around all Hallon objects to avoid polluting
# the global namespace. To start using Hallon, you most likely want to
# be looking for the documentation on {Hallon::Session}.
module Hallon
  # A regex that matches all Spotify URIs
  #
  # @example
  #   Hallon::URI === ("spotify:user:burgestrand") # => true
  URI = /(spotify:(?:
    (?:artist|album|track|user:[^:]+:playlist):[a-zA-Z0-9]+
    |user:[^:]+
    |search:(?:[-\w$\.+!*'(),]+|%[a-fA-F0-9]{2})+
    ))
  /x
end