module Hallon::Observable
  module Post
    def self.extended(other)
      other.send(:include, Hallon::Observable)
    end

    def initialize_callbacks
      callback_for(:complete)
    end

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
      trigger(pointer, :complete)
    end
  end
end
