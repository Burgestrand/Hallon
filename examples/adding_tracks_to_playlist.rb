# coding: utf-8

require_relative 'example_support'
session = Hallon::Session.instance

playlist_uri = loop do
  uri = prompt_link("Give me a Spotify URI to a playlist you wish to modify (and have access to)")
  break uri if uri
end

track_uris = []
loop do
  uri = prompt_link("Give me a Spotify URI to a track you wish to add to the playlist")
  track_uris << uri
  break unless uri
end
track_uris.compact!

# First, we load the playlist. This is necessary for libspotify
# to know if we have write access to it or not. Not doing it might
# end us up getting permission denied errors later.
puts "Loading playlist #{playlist_uri}."
playlist = Hallon::Playlist.new(playlist_uri).load
puts "(it has #{playlist.size} tracks)"

# Convert all track URIs to actual Tracks.
puts "Creating #{track_uris.length} tracks:"
puts track_uris.join("\n")
tracks = track_uris.map { |x| Hallon::Track.new(x) }

# … insert the tracks at the desired position into the playlist.
position = 0
playlist.insert(position, tracks)

# finally, wait for the updates to the playlist to be acknowledged by the
# Spotify back-end. Once they have, we’ll see the tracks in our desktop
# client as well.
puts "Uploading playlist changes to Spotify back-end!"

state_changed = false
playlist.on(:playlist_state_changed) { state_changed = true }
session.wait_for { state_changed && ! playlist.pending? }

puts "We’re done!"
