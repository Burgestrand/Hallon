# coding: utf-8

$LOAD_PATH.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

require 'hallon'
require './spec/support/config'

##
# Configuration
#
# uri to the playlist you wish to add tracks to
playlist_uri = "spotify:user:burgestrand:playlist:07AX9IY9Hqmj1RqltcG0fi"

# array of track uris you wish to add to the playlist
track_uris = %w[spotify:track:6GHrP1i3vQo1e8VkEHRnvz spotify:track:2t7u74OJXHf0qQxXHpnb2R spotify:track:24q7a0Bo5MFLJUslg1lsS5]

# index to add the tracks to in the playlist
position = 0

session = Hallon::Session.initialize IO.read(ENV['HALLON_APPKEY']) do
  on(:log_message) do |message|
    puts "[LOG] #{message}"
  end
end

session.login!(ENV['HALLON_USERNAME'], ENV['HALLON_PASSWORD'])
puts "Successfully logged in!"

# First, we load the playlist. This is necessary for libspotify
# to know if we have write access to it or not. Not doing it might
# end us up getting permission denied errors later.
puts "Loading playlist #{playlist_uri}"
playlist = Hallon::Playlist.new(playlist_uri)
session.wait_for { playlist.loaded? }

# Convert all track URIs to actual Tracks.
puts "Loading #{track_uris.length} tracks"
tracks = track_uris.map { |x| Hallon::Track.new(x) }

# … insert the tracks at the desired position into the playlist.
playlist.insert(position, tracks)

# finally, wait for the updates to the playlist to be acknowledged by the
# Spotify back-end. Once they have, we’ll see the tracks in our desktop
# client as well.
puts "Uploading playlist changes to Spotify back-end!"

state_changed = false
playlist.on(:playlist_state_changed) { state_changed = true }
session.wait_for { state_changed && ! playlist.pending? }

puts "We’re done!"
