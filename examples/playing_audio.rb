# coding: utf-8

$LOAD_PATH.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

require 'hallon'
require_relative '../spec/support/config'

begin
  require 'coreaudio'
rescue LoadError
  abort <<-ERROR
    This example requires the ruby-coreaudio gem.

    See: http://rubygems.org/gems/coreaudio
  ERROR
end

# Utility
def say(string)
  system('say', string)
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

sample_rate = 44100 # 44100 samples / second
device      = CoreAudio.default_output_device
output      = device.output_buffer(sample_rate * 3)
audio_queue = Hallon::Queue.new(sample_rate)

session = Hallon::Session.initialize IO.read(ENV['HALLON_APPKEY']) do
  on(:log_message) do |message|
    puts "[LOG] #{message}"
  end

  on(:connection_error) do |error|
    Hallon::Error.maybe_raise(error)
  end

  on(:logged_out) do
    abort "[FAIL] Logged out!"
  end
end

end_of_track = false
player = Hallon::Player.new(session) do
  on(:music_delivery) do |format, frames|
    audio_queue.push(frames)
  end

  on(:start_playback) do
    puts "(start playback)"
    output.start
  end

  on(:stop_playback) do
    puts "(stop playback)"
    output.stop
  end

  on(:get_audio_buffer_stats) do
    [audio_queue.size, 0]
  end

  on(:end_of_track) do
    puts "End of track!"
    end_of_track = true
  end
end

# Program flow.

session.login!(ENV['HALLON_USERNAME'], ENV['HALLON_PASSWORD'])

search = loop do
  query  = prompt("Enter a search term for a track you’d like to play")
  search = Hallon::Search.new(query)

  tell "Searching for “#{search.query}”…"
  session.wait_for do
    search.loaded? or Hallon::Error.maybe_raise(search.status)
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

player.play(track)

tell "Alright! Playing “#{track.name}” by “#{track.artist.name}”."

until end_of_track
  output << audio_queue.pop(sample_rate)
end

tell "Done! This was “#{track.name}” by “#{track.artist.name}”. Bye bye!"
