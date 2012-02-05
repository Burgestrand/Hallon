# coding: utf-8

$LOAD_PATH.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

require 'bundler/setup'
require 'hallon'

begin
  require 'hallon/openal'
rescue LoadError
  require_relative 'audio_driver'
end

require_relative '../spec/support/config'

# Utility
def say(string)
  # system('say', string)
end

def tell(string)
  puts(string)
  say(string)
end

def prompt(string)
  print(string + ': ')
  $stdout.flush
  say(string)
  gets.chomp
end

# Hallon set-up.

session = Hallon::Session.initialize IO.read(ENV['HALLON_APPKEY']) do
  on(:connection_error) do |error|
    Hallon::Error.maybe_raise(error)
  end

  on(:logged_out) do
    abort "[FAIL] Logged out!"
  end
end

driver = defined?(Hallon::OpenAL) ? Hallon::OpenAL : Hallon::CoreAudio
player = Hallon::Player.new(session, driver)

# Program flow.

session.login!(ENV['HALLON_USERNAME'], ENV['HALLON_PASSWORD'])

search = loop do
  query  = prompt("Enter a search term for a track you’d like to play")
  search = Hallon::Search.new(query)

  tell "Searching for “#{search.query}”…"
  session.wait_for do
    search.loaded? or Hallon::Error.maybe_raise(search.status, ignore: :is_loading)
  end

  if search.tracks.size.zero?
    tell "No results for “#{search.query}”."
    next
  else
    break search
  end
end

tracks = search.tracks[0...10]
session.wait_for { tracks.all?(&:loaded?) }

tell "Results for “#{search.query}”: "
tracks.each_with_index do |track, index|
  puts "  [#{index + 1}] #{track.name} — #{track.artist.name} (#{track.to_link.to_str})"
end
puts

track = loop do
  index = prompt("Choose a track to play (between 1 and #{tracks.size})").to_i

  if track = tracks[index - 1]
    break track
  else
    tell "No such track."
  end
end

tell "Alright! Playing “#{track.name}” by “#{track.artist.name}”."
player.play!(track)
tell "Done! This was “#{track.name}” by “#{track.artist.name}”. Bye bye!"
