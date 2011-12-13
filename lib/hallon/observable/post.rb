module Hallon::Observable
  module Post
    include Hallon::Observable

    # This callback is fired when the Image object is fully loaded.
    #
    # @example listening to this callback
    #   post = user.post(track)
    #   post.on(:complete) do
    #     puts "ze user be havin’ sum posts"
    #   end
    #
    # @yield [self]
    # @yieldparam [User::Post] self
    def complete_callback(pointer, userdata)
      trigger(:complete)
    end
  end
end
