module Hallon::Observable
  # Callbacks related to {Hallon::Image} objects.
  module Image
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
    #   image = Image.new("spotify:image:3ad93423add99766e02d563605c6e76ed2b0e450")
    #   image.on(:load) do
    #     puts "Image has loaded"
    #   end
    #
    # @yield []
    def load_callback(pointer, userdata)
      trigger(pointer, :load)
    end
  end
end

