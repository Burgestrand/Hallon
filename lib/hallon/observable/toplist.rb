module Hallon::Observable
  module Toplist
    include Hallon::Observable

    # This callback is fired when the Image object is fully loaded.
    #
    # @example listening to this callback
    #   toplist.on(:load) do
    #     puts "the toplist has loaded!"
    #   end
    #
    # @yield [self]
    # @yieldparam [Toplist] self
    def load_callback(pointer, userdata)
      trigger(:load)
    end
  end
end

