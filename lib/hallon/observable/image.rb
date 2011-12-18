module Hallon::Observable
  module Image
    def self.extended(other)
      other.send(:include, Hallon::Observable)
    end

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
    # @yield [self]
    # @yieldparam [Image] self
    def load_callback(pointer, userdata)
      trigger(pointer, :load)
    end
  end
end

