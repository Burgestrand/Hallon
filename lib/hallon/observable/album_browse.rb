module Hallon::Observable
  # Callbacks related to {Hallon::AlbumBrowse} objects.
  module AlbumBrowse
    # Includes {Hallon::Observable} for you.
    def self.extended(other)
      other.send(:include, Hallon::Observable)
    end

    protected

    # @return [Method] load callback
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
