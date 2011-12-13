module Hallon::Observable
  module ArtistBrowse
    include Hallon::Observable

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
      trigger(:load)
    end
  end
end

