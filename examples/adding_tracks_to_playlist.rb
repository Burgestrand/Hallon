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

session = Hallon::Session.initialize IO.read(ENV['HALLON_APPKEY']) do
  on(:log_message) do |message|
    puts "[LOG] #{message}"
  end
end

session.login!(ENV['HALLON_USERNAME'], ENV['HALLON_PASSWORD'])
puts "Successfully logged in!"

# First, we load the playlist. I’m not entirely sure if this is really
# necessary, but let’s be on the safe side!
puts "Loading playlist #{playlist_uri}"
playlist = Hallon::Playlist.new(playlist_uri)
session.wait_for { playlist.loaded? }

# Convert all track URIs to actual Tracks. Load these too; again, not
# sure if this is entirely necessary.
puts "Loading #{track_uris.length} tracks"
tracks = track_uris.map { |x| Hallon::Track.new(x) }
session.wait_for { tracks.all?(&:loaded?) }

# … insert the tracks at the desired position into the playlist.
playlist.insert(position, tracks)

# finally, wait for the updates to the playlist to be acknowledged by the
# Spotify back-end. Once they have, we’ll see the tracks in our desktop
# client as well.
#
puts "Uploading playlist changes to Spotify back-end!"

done = false
playlist.on(:playlist_update_in_progress) { |x| done = x }
session.wait_for { done }

puts "We’re done!"
