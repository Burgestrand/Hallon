# coding: utf-8

# Require support code, used by all the examples.
require_relative 'example_support'
session = Hallon::Session.instance

puts "Hi there! I am adding_tracks_to_playlist.rb. You and me, we will manipulate some playlists today.
We shall add a few tracks to a playlist of your choice."

playlist_uri = loop do
  uri = prompt_link("Give me a Spotify URI to a playlist to modify (e. g. spotify:playlist:…)")
  break uri if uri
end

puts "Now I need the tracks we should add to it. Give them all to me. End it with a blank line."
track_uris = []
loop do
  uri = prompt_link("Give me a Spotify URI to a track")
  track_uris << uri
  break unless uri
end
track_uris.compact!

puts "Great. We’ll be adding these babies to #{playlist_uri}."
puts track_uris.join("\n")
puts

# First, we load the playlist. This is necessary for libspotify to know if we
# have write access to it or not. Not doing it might end us up getting permission
# denied errors later.
puts "Loading playlist #{playlist_uri}."
playlist = Hallon::Playlist.new(playlist_uri).load
puts "(it has #{playlist.size} tracks)"

# Convert all track URIs to actual Tracks.
tracks = track_uris.map { |x| Hallon::Track.new(x) }

# … insert the tracks at the desired position into the playlist.
position = 0
playlist.insert(position, tracks)

# finally, wait for the updates to the playlist to be acknowledged by the
# Spotify back-end. Once they have, we’ll see the tracks in our desktop
# client as well.
puts "Uploading playlist changes to Spotify back-end!"

# We allow a timeout of 30 seconds. These things sometimes take a long time.
playlist.upload

puts "We’re done!"
