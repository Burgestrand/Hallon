# coding: utf-8
require 'hallon'
require './spec/support/config'

##
# Configuration
#
# uri to the playlist you wish to add tracks to
playlist_uri = "spotify:user:burgestrand:playlist:07AX9IY9Hqmj1RqltcG0fi"

# array of track uris you wish to add to the playlist
track_uris = %w[spotify:track:6GHrP1i3vQo1e8VkEHRnvz]

# index to add the tracks to in the playlist
position = 0

##
# Hallon / Spotify API usage
#
# The example below uses a mix of Hallon and Spotify (libspotify-ruby) API;
# once Hallon covers all of the API usage this document will be updated to
# reflect the new changes.
session = Hallon::Session.initialize IO.read(ENV['HALLON_APPKEY']) do
  on(:log_message) do |message|
    puts "[LOG] #{message}"
  end
end

session.login ENV['HALLON_USERNAME'], ENV['HALLON_PASSWORD']
session.wait_for(:logged_in) { |error| Hallon::Error.maybe_raise(error) }
session.wait_for(:connection_error) do |error|
  session.logged_in? or Hallon::Error.maybe_raise(error)
end

puts "Successfully logged in!"

# First, we load the playlist. I’m not entirely sure if this is really
# necessary, but let’s be on the safe side!
puts "Loading playlist #{playlist_uri}"
playlist = Hallon::Playlist.new(playlist_uri)
session.wait_for { playlist.loaded? }

# Then we convert all track URIs to actual tracks. Once again, I’m not
# sure you really need to load all tracks, but better safe than sorry.
puts "Loading #{track_uris.length} tracks"
tracks = track_uris.map { |x| Hallon::Track.new(x) }
session.wait_for { tracks.all?(&:loaded?) }

# Adding tracks to the playlist means we must drop down to raw Spotify API
# because Hallon does not support it yet. Luckily, it’s still Ruby!
#
# Passing a block to FFI::MemoryPointer means it’ll be automatically freed
# once the block finishes. We must create this pointer because the Spotify
# API takes a C array of track pointers, so we store them in this pointer.
FFI::MemoryPointer.new(:pointer, tracks.length) do |tracks_ary|
  tracks_ary.write_array_of_pointer tracks.map(&:pointer)

  # finally, add all the tracks to the playlist and check for failure
  print "Adding tracks to playlist: "
  error = Spotify.playlist_add_tracks(playlist.pointer, tracks_ary, tracks.length, position, session.pointer)
  puts error
  Hallon::Error.maybe_raise(error)
end

# finally, wait for the updates to the playlist to be acknowledged by the
# Spotify back-end. Once they have, we’ll see the tracks in our desktop
# client as well.
#
puts "Uploading playlist changes to Spotify back-end"

# there’s a tiny bug in Playlist#pending? in libspotify that makes it 
# return false after adding tracks to a playlist unless you first call
# Session#process_events
session.process_events
session.wait_for { not playlist.pending? }

puts "We’re done!"
