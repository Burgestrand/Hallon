require 'hallon/version'
require 'hallon/session'

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