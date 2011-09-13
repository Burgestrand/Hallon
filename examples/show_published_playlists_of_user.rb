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

session.login ENV['HALLON_USERNAME'], ENV['HALLON_PASSWORD']

session.wait_for(:logged_in) { |error| Hallon::Error.maybe_raise(error) }
session.wait_for(:connection_error) do |error|
  session.logged_in? or Hallon::Error.maybe_raise(error)
end

puts "Successfully logged in!"

# Hallon does not have support for the below operations, so we resort
# to using the raw Spotify gem and FFI for now.
while username = prompt("Enter a Spotify username: ")
  begin
    username  = nil if username.empty?

    puts "Fetching container for #{username || "current user"}..."
    container = Spotify::session_publishedcontainer_for_user_create(session.pointer, username)
    if container.nil?
      puts "Failed (unknown reason)."
      next
    end

    session.wait_for { Spotify::playlistcontainer_is_loaded(container) }

    num_playlists = Spotify::playlistcontainer_num_playlists(container)
    puts "Listing #{num_playlists} playlists."

    num_playlists.times do |i|
      playlist = Spotify::playlistcontainer_playlist(container, i)
      session.wait_for { Spotify::playlist_is_loaded(playlist) }

      puts
      puts Spotify::playlist_name(playlist) << ": "

      num_tracks = Spotify::playlist_num_tracks(playlist)
      num_tracks.times do |j|
        # Here we go back into Hallon API, passing the raw pointer
        # to Hallon::Track.new; this means all of Hallon::Track API
        # is supported on “track” here!
        track = Hallon::Track.new(Spotify::playlist_track(playlist, j))
        session.wait_for { track.loaded? }

        puts "\t (#{j+1}/#{num_tracks}) #{track.name}"
      end
    end
  rescue Interrupt
    # do nothing, continue with loop
  ensure
    Spotify::playlistcontainer_release(container) unless container.nil?
  end
end
