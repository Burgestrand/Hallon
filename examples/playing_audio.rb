# coding: utf-8

# Require support code, used by all the examples.
require_relative 'example_support'
session = Hallon::Session.instance

begin
  require 'hallon/openal'
rescue LoadError => e
  puts e.message
  abort "[ERROR] Could not load gem 'hallon-openal', please install with 'gem install hallon-openal'"
end

player = Hallon::Player.new(session, Hallon::OpenAL)

# Program flow.

search = loop do
  query  = prompt("Enter a search term for a track you’d like to play")
  search = Hallon::Search.new(query)

  puts "Searching for “#{query}”…"
  search.load

  if search.tracks.size.zero?
    puts "No results for “#{search.query}”."
    next
  else
    break search
  end
end

tracks = search.tracks[0...10].map(&:load)

puts "Results for “#{search.query}”: "
tracks.each_with_index do |track, index|
  puts "  [#{index + 1}] #{track.name} — #{track.artist.name} (#{track.to_link.to_str})"
end
puts

track = loop do
  index = prompt("Choose a track to play (between 1 and #{tracks.size})").to_i

  if track = tracks[index - 1]
    break track
  else
    puts "No such track."
  end
end

puts "Alright! Playing “#{track.name}” by “#{track.artist.name}”."
player.play!(track)
puts "Done! This was “#{track.name}” by “#{track.artist.name}”. Bye bye!"
