$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require File.expand_path('../../spec/support/config', __FILE__)

require 'bundler/setup'
require 'hallon'
require 'pry'

session = Hallon::Session.initialize IO.read(ENV['HALLON_APPKEY'])
session.login! ENV['HALLON_USERNAME'], ENV['HALLON_PASSWORD']

binding.pry
