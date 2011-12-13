module Hallon::Observable
  module Search
    include Hallon::Observable

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
      trigger(:load)
    end
  end
end
