# coding: utf-8
#
# DISCLAIMER:
# This file was written without extensive testing, and is merely a proof
# of concept. Before using this yourself, I advice you to look through
# the code carefully.
#
# The below code uses the raw Spotify FFI API, and does not represent how
# this will be done when Hallon has API support for below operations!
#
# Hallon API in this file is only used for:
# - logging in
# - querying track information
#
# Raw Spotify FFI API is used for:
# - fetching playlist container
# - fetching playlists
# - fetching tracks from playlists
require 'hallon'
require './spec/support/config'

# Utility
def prompt(str)
  print str
  gets.chomp
end

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

session.login!(ENV['HALLON_USERNAME'], ENV['HALLON_PASSWORD'])

puts "Successfully logged in!"

while username = prompt("Enter a Spotify username: ")
  begin
    puts "Fetching container for #{username}..."
    published = Hallon::User.new(username).published
    session.wait_for { published.loaded? }

    puts "Listing #{published.size} playlists."
    published.contents.each do |playlist|
      next if playlist.nil? # folder or somesuch

      session.wait_for { playlist.loaded? }

      puts
      puts playlist.name << ": "

      playlist.tracks.each_with_index do |track, i|
        session.wait_for { track.loaded? }

        puts "\t (#{i+1}/#{playlist.size}) #{track.name}"
      end
    end
  rescue Interrupt
    # do nothing, continue with loop
  end
end
