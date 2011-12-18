module Hallon::Observable
  module Search
    def self.extended(other)
      other.send(:include, Hallon::Observable)
    end

    def initialize_callbacks
      callback_for(:load)
    end

    # This callback is fired when the Image object is fully loaded.
    #
    # @example listening to this callback
    #   search.on(:load) do |search|
    #     puts "search for #{search.query} is complete!"
    #   end
    #
    # @yield [self]
    # @yieldparam [Search] self
    def load_callback(pointer, userdata)
      trigger(pointer, :load)
    end
  end
end