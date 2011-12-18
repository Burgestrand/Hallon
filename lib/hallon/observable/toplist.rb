module Hallon::Observable
  module Toplist
    def self.extended(other)
      other.send(:include, Hallon::Observable)
    end

    def initialize_callbacks
      callback_for(:load)
    end

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
      trigger(pointer, :load)
    end
  end
end

