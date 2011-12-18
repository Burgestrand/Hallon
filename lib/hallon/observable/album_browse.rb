module Hallon::Observable
  module AlbumBrowse
    def self.extended(other)
      other.send(:include, Hallon::Observable)
    end

    def initialize_callbacks
      callback_for(:load)
    end

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
      trigger(pointer, :load)
    end
  end
end
