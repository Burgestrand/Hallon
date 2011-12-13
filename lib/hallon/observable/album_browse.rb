module Hallon::Observable
  module AlbumBrowse
    include Hallon::Observable

    # This callback is fired when the AlbumBrowse object is fully loaded.
    #
    # @example listening to this callback
    #   browse = AlbumBrowse.new(album)
    #   browse.on(:load) do
    #     puts "Album browser has loaded!"
    #   end
    #
    # @yield [self]
    # @yieldparam [AlbumBrowse] self
    def load_callback(pointer, userdata)
      trigger(:load)
    end
  end
end
