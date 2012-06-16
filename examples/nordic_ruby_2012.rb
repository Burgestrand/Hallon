# coding: utf-8

# Require support code, used by all the examples.
require_relative 'example_support'
session = Hallon::Session.instance

require 'pry'

begin
  require 'hallon/openal'
rescue LoadError => e
  puts e.message
  abort "[ERROR] Could not load gem 'hallon-openal', please install with 'gem install hallon-openal'"
end

puts "Creating Player."
player = Hallon::Player.new(Hallon::OpenAL)

puts "Loading track."
track  = Hallon::Track.new("spotify:track:7Az9kfq4JLD8auD1xoErrP").load
player.load(track)
player.seek(9.8)

binding.pry
