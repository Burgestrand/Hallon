module Hallon::Observable
  module ArtistBrowse
    def self.extended(other)
      other.send(:include, Hallon::Observable)
    end

    def initialize_callbacks
      callback_for(:load)
    end

    # This callback is fired when the ArtistBrowse object is fully loaded.
    #
    # @example listening to this callback
    #   browse = ArtistBrowse.new(album)
    #   browse.on(:load) do
    #     puts "Artist browser has loaded!"
    #   end
    #
    # @yield [self]
    # @yieldparam [ArtistBrowse] self
    def load_callback(pointer, userdata)
      trigger(pointer, :load)
    end
  end
end

