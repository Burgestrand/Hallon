module Hallon::Observable
  # We only care about a few of the Session callbacks, actually,
  # but since this object is not *really* a Spotify object we do
  # cheat a little bit.
  module Player
    # Includes {Hallon::Observable} for you.
    def self.extended(other)
      other.send(:include, Hallon::Observable)
    end

    include Hallon::Observable::Session
  end
end
