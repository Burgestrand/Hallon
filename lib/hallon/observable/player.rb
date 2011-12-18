module Hallon::Observable
  # We only care about a few of the Session callbacks, actually,
  # but since this object is not *really* a Spotify object we do
  # cheat a little bit.
  Player = Session
end
