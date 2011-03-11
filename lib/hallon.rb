# coding: utf-8
require 'hallon_ext'
require 'hallon/error'
require 'hallon/version'

require 'hallon/base'
require 'hallon/session'
require 'hallon/link'

# YARD have a habit of showing my “coding”-declarations. Since everything is
# enclosed in a Hallon module, it removes my C-docs and puts the encoding line
# there instead. This method is to prevent anything like that from happening.
def hallon_yard_fix
end

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