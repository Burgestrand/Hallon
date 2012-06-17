module Hallon::Observable
  # Callbacks related to the {Hallon::Toplist} object.
  module Toplist
    # Includes {Hallon::Observable} for you.
    def self.extended(other)
      other.send(:include, Hallon::Observable)
    end

    protected

    # @return [Method] load callback
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
    # @yield []
    def load_callback(pointer, userdata)
      trigger(pointer, :load)
    end
  end
end

